#!/usr/bin/perl -w
sub isArray
{
	if( @_ == 0 )
	{
		print("1 argumen unexpect\n");
		return;
	}
	return (ref($_[0]) eq 'ARRAY')?1:0;
}
sub debugScalar
{
	($package, $filename, $line) = caller;
	print "------------------debug----------------------\n";
	print "call to: $package : $filename : $line \n";
	if( @_ == 0 )
	{
		warn("1 argumen unexpect\n");
		return;
	}
	elsif( ref($_[0]) eq "HASH" or ref($_[0]) eq "ARRAY" ) 
	{
		warn("argument no ARRAY\n");
		return;
	}
	elsif( not ref($_[0]) ) 
	{
		warn("not is reference\n");
		return;
	}
	print "Type:".ref($_[0])."\n";
	my $arg = $_[0];
	print "value:<$$arg>\n";
	print "---------------end debug-------------------------\n";
}
#@brief debug a List
sub debugList
{
	print "------------------debug----------------------\n";
	($package, $filename, $line) = caller;
	print "call to: $package : $filename : $line \n";
	if( @_ == 0 )
	{
		warn("1 argumen unexpect\n");
		return;
	}
	elsif( not ref($_[0]) ) 
	{
		print ("not is reference\n");
		return;
	}
	my $count = 0;
	my $list = $_[0];
	unless( ref(@$list) ne "ARRAY") 
	{
		print ("argument no ARRAY\n");
		return;
	}
	print "\t.... list .....\n";
	foreach ( @$list )
	{
		print"\t$count:$_\n";
		$count++;
	}
	print "tot:$count\n";
	print "---------------end debug-------------------------\n";
}
sub debugHash
{
	print "------------------debug----------------------\n";
	($package, $filename, $line) = caller;
	print "---- call to: $package : $filename : $line \n";
	if( @_ == 0 )
	{
		warn("1 argumen unexpect\n");
		return;
	}
	elsif( not ref($_[0]) ) 
	{
		warn("not is reference\n");
		return;
	}
	my $count = 0;
	my $hash  = $_[0];
	unless( ref(%$hash) ne "HASH") 
	{
		warn("argument no HASH\n");
		return;
	}
	print ".... hash .....\n";
	foreach ( keys %$hash )
	{
		print "<$_> -> <$hash{$_}>\n";
		$count++;
	}
	print "tot:$count\n";
	print "---------------end debug-------------------------\n";
}
1;
