# Copyright (C) 1999 Lucent Technologies
# Excerpted from 'The Practice of Programming'
# by Brian W. Kernighan and Rob Pike

# markov.pl: markov chain algorithm for 2-word prefixes

$MAXGEN = 10000;
$NONWORD = "####";
$w1 = $w2 = $NONWORD;           # initial state
while (<>) {                    # read each line of input
	foreach (split) {
		push(@{$statetab{$w1}{$w2}}, $_);
		($w1, $w2) = ($w2, $_);	# multiple assignment
	}
}
push(@{$statetab{$w1}{$w2}}, $NONWORD); 	# add tail

# Dump the state transition probabilities for the input text

print "KNOWN_ANSWER_STATES = {\n";

$firstW1 = 1;

foreach $w1 (sort(keys(%statetab))) {
	if ($firstW1) {
		$firstW1 = 0;
	} else {
		print ",\n";
	}

	print "\t" . escape_string($w1) . " => {\n";

	$firstW2 = 1;
	foreach $w2 (sort(keys(%{$statetab{$w1}}))) {
		if ($firstW2) {
			$firstW2 = 0;
		} else {
			print ",\n";
		}
		print "\t\t" . escape_string($w2) . " => [";


		@words = ();
		foreach $word (@{$statetab{$w1}{$w2}}) {
			push(@words, escape_string($word));
		}
			
		$word_list = join(", ", @words);
		
		print $word_list;
		print "]";
	}
	print "\n\t}";
}

print "\n}\n";

sub escape_string {
	($string) = @_;
	$string =~ s/\'/\\\'/g;
	$string =~ s/\n/\\n/g;

	"'" . $string . "'";
}

