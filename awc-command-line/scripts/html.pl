#!/usr/bin/perl -w
sub createTable
{
	my( $header,$rows ) = @_;
	$table = '<table>';
	$table .='	<tr>';
	foreach $td( @$header )
	{
		$table .= '		<th>'.$td.'</th>';
	}
	$table .='	</tr>';
	foreach( @$rows )
	{
		my @aux = split /\#\$\#/;
		$table .= '<tr>';
		foreach $row( @aux )
		{
			
			$table .= '<td>'.$row.'</td>';
			
		}
		$table .= '</tr>';
	}
	$table .= '</table>';
	return $table;
}
sub createList
{
	my( $rows ) = @_;
	$ul = '<ul>';
	foreach$row( @$rows )
	{	
		$ul .= '<li><a href="'.$row.'">'.$row.'</a></li>';
	}
	$ul .= '</ul>';
	return $ul;
}
1;
