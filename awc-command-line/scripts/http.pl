#!/usr/bin/perl -w
# checklinks -- Check Hypertext 
# investigar un poco duro: http://search.cpan.org/~jfearn/HTML-Tree-4.2/lib/HTML/Tree/Scanning.pod
#------------------------------------
# Copyright (C) 1996  Jim Weirich.
# All rights reserved. Permission
# is granted for free use or
# modification.
# Copyright (C) 2012 Antonio Jaime Rodríguez Medina
# All rights reserved. Permission
# is granted for free use or
# modification.
#------------------------------------
########################################source 
#source http://www.linuxjournal.com/files/linuxjournal.com/linuxjournal/articles/020/2026/2026l1.html
#article  http://www.linuxjournal.com/article/2026?page=0,1
########################################
use HTML::LinkExtor;
use HTTP::Request; # All the knowledge about fetching a document across the Web is stored in a UserAgent object
use LWP::UserAgent;
use LWP::Simple;
use URI::URL;
use Encode;
require 'scripts/utils.pl';
require 'scripts/html.pl';
$version = '1.0';
$verbose = undef;
$levels = 15;
$ref_exclude = undef;
$ref_include= undef;
$recursive= undef;
$verbose= undef;
$ref_extensions= undef;
$delay= undef;
$file= undef;
$report= undef;
$levels= undef;
$iniFile= undef;
$contains = undef;
####
	## Initialize our bookkeeping arrays
	@tobeScanned = ();
	# list of URLs to be scanned
	@goodUrls    = ();
	# list of good URLs
	@badUrls     = ();
	# list of bad URLs
	@isScanned   = ();
	# list of scanned URLs
	%refs        = ();
	@brokenScanned = ();
	# reference lists
	# list of scanned URLs
	%refs_types        = ();
	%refs_codes        = ();
	# list contains
	@listContains = ();
#####
$site = '';
sub init
{
	($url,$ref_exclude,$find,$ref_include,$recursive,$verbose,$ref_extensions,$delay,$file,$report,$levels,$iniFile) = @_;
	$localprefix = $url;
	$site = $url;
	$localprefix =~ s%[^/]*$%%;
	print "Local Prefix = $localprefix\n" if $verbose;
	@tobeScanned = ($url);
	# Create the global parser and
	# user agent.
	### erjaimer 
	# HTML::LinkExtor - Extract links from an HTML document
	$parser = new HTML::LinkExtor (\&HandleParsedLink);
	#erjaimer 
	# Web user agent class
	# The LWP::UserAgent is a class implementing a web user agent. LWP::UserAgent objects can be used to dispatch web requests.
	$agent  = new LWP::UserAgent();
	# Keep Scanning and Checking until
	# there are no more URLs
	while (@tobeScanned || @tobeChecked) 
	{
		while (@tobeChecked) 
		{
			my $url = shift @tobeChecked;
			CheckUrl ($url);
		}
	    	if (@tobeScanned) 
		{
	   		my $url = shift @tobeScanned;
	   		ScanUrl ($url);
	   	}
	}
}
# HandleParsedLink
#---------------------------------
# HandleParsedLink is a callback
#provided for parsing handling HTML
# links found during parsing.  $tag
# is the HTML tag where the link was
# found. %links is a hash that contains
# the keyword/value pairs from
# the link that contain URLs. For
# example, if an HTML anchor was
# found, the $tag would be "a"
# and %links would be (href=>"url").
# We check each URL in %links. We make
# sure the URL is absolute
# rather than relative. URcontainsLs that don't
# begin with "http:" or "file:"
# are ignored. Bookmarks following a "#"
# character are removed.
# If we have not seen this URL yet, we
# add it to the list of URLs to
# be checked. Finally, we note where
# the URL was found it its list of
# references.
sub HandleParsedLink 
{
	my ($tag, %links) = @_;
	$refs_types{$currentUrl} = $tag;
	for $url (values %links) 
	{
		my $urlobj = new URI::URL $url, $currentUrl;
		$url = $urlobj->abs;
		next if $url !~ /^(http|file):/; #not support protocols
		$url =~ s/#.*$//;
		if (!$refs{$url}) 
		{
			$refs{$url} = [];
			push (@tobeChecked, $url);
		}
		push (@{$refs{$url}}, $currentUrl) unless (existsInArray( \@{$refs{$url}}, $currentUrl ));
	}
	1;#what?
}
# HandleDocChunk
#--------------------------------
# HandleDocChunk is called by the
# UserAgent as the web document is
# fetched. As each chunk of the
# document is retrieved, it is passed
# to the HTML parser object for further
# processing (which in this
# case, means extracting the links).
sub HandleDocChunk 
{
	my ($data, $response, $protocol) = @_;
	$DATA = $data;
	$parser->parse (decode_utf8($data));
    
}
# ScanUrl
# ------------------------------
# We have a URL that needs to be
# scanned for further references to
# other URLs. We create a request to
# fetch the document and give that
# request to the UserAgent responsible
# for doing the fetch.

sub ScanUrl 
{
	my($url) = @_;
	$currentUrl = $url;
	if( countLevels($url) > $levels )
	{
		return;
	}
	push (@isScanned, $url);
	print "Scanning $url\n" if $verbose;
	if( $url !~ m/^$site/ ) # no extern links
	{
		return;
	}
	$DATA = '';
	if( $delay > 0 )
	{
		sleep( $delay );
	}
	$request  = new HTTP::Request (GET => $url);
	$response = $agent->request ($request, \&HandleDocChunk);
	foreach $contain(@$contains )
	{
		push(@listContains,$url)  if ( $DATA =~ /$contain/ );
	}
	$DATA = '';
    if ($response->is_error) 
	{
    	warn "Can't Fetch URL $url\n";
		push(@brokenScanned,$url);
    }
	print 'CODE:'.$response->code( )."\n" if ( $verbose );
	$refs_codes{$url} = $response->code(); #get code
	$parser->eof;
}

# CheckUrl
# ------------------------------
# We have a URL that needs to be
# checked and validated. We attempt
# to get the header of the document
# using the head() function. If this
# fails, we add the URL to our list
# of bad URLs. If we do get the
# header, the URL is added to our
# good URL list. If the good URL
# is part of our local web site
#(i.e. it begins with the local
# prefix), then we want to scan
# this URL for more references.
sub CheckUrl {
	my($url) = @_;
	print "    Checking $url\n" if $verbose;
	foreach $ext( @$extensions )
	{
		my $regex =$ext;
		if( $url =~ /$regex/ )
		{
			return;
		}
	}
	foreach $exc( @$exclude )
	{
		if( $url =~ /$exc/ )
		{
			return;
		}
	}
	foreach $find( @$inurl )
	{
		if( $url !~ /$find/ )
		{
			return;
		}
	}
	$head = head ($url);
	
	if (!$head) 
	{
		push (@badUrls, $url) unless( existsInArray (\@badUrls, $url) );
	} 
	else 
	{
		push (@goodUrls, $url) unless( existsInArray(\@goodUrls, $url));
		if ($url =~ /^$localprefix/ and $recursive) 
		{
			push (@tobeScanned, $url) unless( existsInArray(\@tobeScanned, $url));
		}
	}
}
sub printResults
{
	if( !$report )
	{
		$verbose = 1;
	}
	# Print the results.
	if( $verbose )
	{
		print "Scanned URLs: ", join (" ",sort @isScanned), "\n";
		print "\n";
		print "Good URLs: ", join (" ", sort @goodUrls), "\n";
		print "\n";
		print "Bad URLs: ", join (" ", sort @badUrls), "\n";
	
	print "Good \n";
	foreach ( sort @goodUrls)
	{
		print $_."\n";
	}
	print "\n";
	print "Bad \n";
	for $url (sort @badUrls) 
	{
		print "BAD URL $url referenced in ...\n";
		for $ref (sort @{$refs{$url}}) 
		{
			print "... $ref\n";
		}
		print "\n";
	}
	print "Broken\n";
	foreach$url( @brokenScanned )
	{
		print "... $url\n";
		print "\n";
	}
	print "Contains\n";
	foreach  $url (  @listContains )
	{
		print "... $url and type $refs_types{$url}\n";
		print "\n";
	}

	print int (@isScanned), " URLs Scanned\n";
	print int (keys %refs), " URLs checked\n";
	print int (@goodUrls), " good URLs found\n";
	print int (@badUrls),  " bad  URLs found\n";

}
	if( $report )
	{
		#structo of report
		#	
			print "Generate report html ...... \n";
			open REPORT_HTML,'>'.$file or die $!;
			print REPORT_HTML '<html>';
			print REPORT_HTML '<h3> REPORT OF "'.$url.'"</h3>';
			#### opt
			 ################
			my @header_options =  ('config','value');
			my @body_options = (
								"url\#\$\#$url",
								"verbose\#\$\#$verbose",
								"delay\#\$\#$delay",
								"file\#\$\#$file",
								"report\#\$\#$report",
								"levels\#\$\#$levels",
								"iniFile\#\$\#$iniFile",
								"contains\#\$\#".join(' ',@$contains),
								"include\#\$\#".join(' ',@$include),
								"exclude\#\$\#".join(' ',@$exclude),
								"extensions\#\$\#".join(' ',@$extensions)
								);
			print REPORT_HTML createTable(\@header_options,\@body_options );
			print REPORT_HTML '<h2> Summary </h2>';
			print REPORT_HTML int (@isScanned), " URLs Scanned</p>";
			print REPORT_HTML int (keys %refs), " URLs checked</p>";
			print REPORT_HTML int (@goodUrls), " good URLs found</p>";
			print REPORT_HTML int (@badUrls),  " bad  URLs found</p>";
			print REPORT_HTML int (@brokenScanned),  " broken  URLs found</p>";
			print REPORT_HTML int (@listContains),  " list contains  URLs found</p>";
						#CHECKED
			print REPORT_HTML '<h3>URL CHECKED</h3>';
			my @keys_ref = keys %refs;
			$ul = createList( \@keys_ref );
			print REPORT_HTML $ul;
			#SCANNED
			print REPORT_HTML '<h3>URL SCANNED</h3>';
			print REPORT_HTML '<ul>';
			foreach $url( @isScanned )
			{
				my $code = $refs_codes{$url};
				my $type = $refs_types{$url};
				print REPORT_HTML "<li>
										<p><a href=\"$url\">$url</a>	</p>
										<p>Code:$code		</p>
										<p>Type: $type	</p>
									</li>";
			}
			print REPORT_HTML '</ul>';
			#URL GOOD
			print REPORT_HTML '<h3>URL GOOD</h3>';
			print REPORT_HTML '<ul>';
			for $url (sort @goodUrls) 
			{
				print REPORT_HTML "<li><a href=\"$url\">$url</a></p> </p>";
				print REPORT_HTML "<p>Referenced in ...\n</p>";
				print REPORT_HTML '<ul>';
				for $ref (sort @{$refs{$url}}) 
				{
					print REPORT_HTML "<li><a href=\"$ref\">$ref</a></li>";
				}
				print REPORT_HTML '</ul>';
				print REPORT_HTML '</li>';
			}
			#BAD
			print REPORT_HTML '<h3>URL BAD</h3>';
			print REPORT_HTML '<ul>';
			for $url (sort @badUrls) 
			{
				my $code = $refs_codes{$url};
				my $type = $refs_types{$url};
				
				print REPORT_HTML "<li>
										<p><a href=\"$url\">$url</a>	</p>
									";
				print REPORT_HTML "<p>Referenced in ...\n</p>";
				print REPORT_HTML '<ul>';
				for $ref (sort @{$refs{$url}}) 
				{
					print REPORT_HTML "<li><a href=\"$ref\">$ref</a></p></li>";
				}
				print REPORT_HTML '</ul>';
				print REPORT_HTML '</li>';
			}
			print REPORT_HTML '</ul>';
			#CONTAIN
			print REPORT_HTML '<h3>URL Contains</h3>';
			$ul = createList(  \@listContains );
			print REPORT_HTML $ul;
			#BROKEN
			print REPORT_HTML '<h3>URL Broken</h3>';
			$ul = createList(  \@brokenScanned );
			print REPORT_HTML $ul;
			print REPORT_HTML '</html>';
			close REPORT_HTML or die $!;
			print "end report html\n";
	}
}
1;
