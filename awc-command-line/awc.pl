#!/usr/bin/perl -w
require 'scripts/http.pl';
require 'scripts/csv.pl';
require 'scripts/debug.pl';
require 'scripts/http.pl';
use Getopt::Long;
use Config::Simple; #sudo apt-get install libconfig-simple-perl #http://search.cpan.org/~sherzodr/Config-Simple-4.59/Simple.pm
#####################
####### MAIN ########
#####################
$url = '';
$exclude = undef;
$inurl = undef;
$recursive = 0;
$verbose = 0;
$extensions = ('php');
$delay = 0;
$file='text.csv';
$report=0;
$levels=1;
$iniFile = 'etc/default.ini';
$contains = undef;
if( -e $iniFile  )
{
	Config::Simple->import_from($iniFile, \%Config);#read_config file
	$url = $Config{'site.url'};
	$exclude = $Config{'default.exclude'};
	$find = $Config{'default.find'};
	$contains = $Config{'default.contains'};
	$include = $Config{'default.inurl'};
	$recursive = $Config{'default.recursive'};
	$verbose = $Config{'default.verbose'};
	$extensions = $Config{'default.extensions'};
	$delay = $Config{'default.delay'};
	$file=$Config{'default.file'};
	$report=$Config{'default.report'};
	$levels=$Config{'default.levels'};	
}
GetOptions(
		'exclude=s{,}' => \$exclude 
		,'inurl=s{,}' => \$inurl
		,'contains=s{,}' => \$contains
		,'extensions=s{,}' => \$extensions
		,'levels=i' => \$levels
		,'file' => \$file
		,'url=s' => \$url
		,'verbose!' => \$verbose # --noverbose
		,'report!' =>  \$report
) or die 'Invalid option ';
#### debug results  .......
if( !isArray( $extensions) )
{
	@arr = ( $extensions );
	$extensions = \@arr;
}
if( !isArray( $include) )
{
	@arr1 = ( $include );
	$include = \@arr1;
}
if( !isArray( $exclude) )
{
	@arr2 = ( $exclude );
	$exclude = \@arr2;
}
if( !isArray( $contains) )
{
	@arr3 = ( $contains );
	$contains = \@arr3;
}
###########################
init($url,$exclude,$find,\@include,$recursive,$verbose,$extensions,$delay,$file,$report,$levels,$iniFile);
printResults();
__END__
