use Library::CallNumber::LC;
my $a = Library::CallNumber::LC->new($ARGV[0]);
print $a->normalize;
