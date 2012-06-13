use Text::CSV; # libtext-csv-perl 
#http://stackoverflow.com/questions/4652247/need-some-help-writing-to-a-csv-file
sub writeCSV
{
	my ($file,$arr) = ($_[0],$_[1]);
	my $csv = Text::CSV->new ( { always_quote => 1 } );
	open my $fh, '>', $file or die $!;
	$csv->print( $fh, $arr );
}
1;
