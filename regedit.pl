my %REG_current_hash = {};
my %REG_previous_hash = {};
my @myFile = ();
my $PrevRegEntries = "PrevRegEntires.txt";
my $RegConfig = "Regconfig.cfg";

if ( -e $PrevRegEntries )
{
  if (defined(open (REG_ENTRIES, "<$PrevRegEntries")))
	{
		while (<REG_ENTRIES>)
		{
			my($Key,$value) = split(":",$_);
			print "The value of Key is $Key and the value is $value \n";
			chomp ($value);
			$REG_previous_hash{$Key} = $value;
		}
		close (REG_ENTRIES);
	}
}

if (defined(open (REG_CONFIG, $RegConfig)))
{
	while (<REG_CONFIG>)
	{	
		next if ($_ =~ /^#/);
		next if ($_ =~ /^\s+$/);
		my ($REG_ENTRY, $ValueName) = split (":", $_);
		chomp($ValueName);
		if (defined(open (REGQUERY,"REG QUERY \"$REG_ENTRY\" \/v $ValueName 2>&1 |")))
		{
			while (<REGQUERY>)
			{
				if ($_ =~ /ERROR/ )
				{
					print "The system was unable to find the specified registry key $REG_ENTRY or value $ValueName \n";
				}
				next if ($_ =~ /^\s+$/);
				if ($_ =~ /^\s+$ValueName/)
				{
					my($Key,$reg_string,$value) = split(" ",$_);
					$Key = $REG_ENTRY."\\".$Key;
					$REG_current_hash{$Key} = $value;
					push(@myFile, $Key.":".$value);
					print "The value of Key is $Key and the value is $value \n";
				}
			}
			close (REGQUERY);
		}
	}
	close (REG_CONFIG);
}

my $AlertString = "";
foreach $key( keys %REG_previous_hash)
{
	if ($REG_previous_hash{$key} ne $REG_current_hash{$key})
	{
		$AlertString = "Value of the Registry entry $key was : Previous $REG_previous_hash{$key} | Current $REG_current_hash{$key} \n".$AlertString;
	}
}

#Print the current values to the file	
open (REG_ENTRIES, ">$PrevRegEntries");
foreach ( @myFile )
{
	print REG_ENTRIES "$_\n";
}
close (REG_ENTRIES);

if ($AlertString)
{
	print "There has been changes in the Registry key. Please find the list of them with their previous and current values: \n";
	print $AlertString;
}
