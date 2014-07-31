# Pass in call numbers separated by commas, it returns call numbers separated
# by commas
use Library::CallNumber::LC;
@call_nums = split(',',<STDIN>);
@normed = map { Library::CallNumber::LC->normalize($_) } @call_nums;
print(join(',',@normed));
