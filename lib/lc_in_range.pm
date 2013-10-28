use Library::CallNumber::LC;
my $start = Library::CallNumber::LC->new($ARGV[1]);
my $end = Library::CallNumber::LC->new($ARGV[2]);
my @range = ($start->start_of_range, $end->end_of_range);
my $a = Library::CallNumber::LC->new($ARGV[0]);
if ($a ~~ @range) {
    print "1";
} else {
    print "0";
}
