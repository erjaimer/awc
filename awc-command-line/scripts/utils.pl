#!/usr/bin/perl -w
#@author Antonio Jaime Rodríguez Medina, Bujío Digital
sub existsInArray
{
	my ($array,$element) = @_;
	foreach( @$array )
	{
			return 1 if( "$_" eq "$element");
	}
	return 0;
}
sub countLevels
{
		my $url = $_[0];
		my $num = () = ($url =~ /\//gi); # because http://  or s/\:\/\///
		return int ($num) -2;
}
sub read_file
{
	my $file = $_[0];
	my $text = '';
	open FILE ,$file or die 'No se ha podido abrir '.$file."\n";
		my @lista = <FILE>;
		foreach( @lista ){ $text .= $_; }
	close FILE or die $!;
	return $text;
}
sub write_file
{
	my ( $file,$text) = ($_[0],$_[1]);
	open FILE ,'>'.$file or die 'No se ha podido abrir '.$file."\n";
	print FILE $text;
	close FILE or die $!;
}
sub convert_Carray_Cvector
{
	my $cad = $_[0];
	s/\n//g;
	my @char_array = split(//,$cad);
	print @char_array;
	my $newCad = '';
	for($i = 0; $i < $#char_array + 1; $i++)
	{
		$char_array[$i] =  "'".$char_array[$i]."'";
	}
	return join(',',@char_array);
}
1;
