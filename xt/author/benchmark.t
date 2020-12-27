use strict;
use warnings;
use Test::More;
use IO::File;
use Benchmark qw(countit);
use JavaScript::Minifier::XS;

###############################################################################
# check if JavaScript::Minifier available, so we can do comparison testing
eval { require JavaScript::Minifier };
if ($@) {
    plan skip_all => 'JavaScript::Minifier not available for benchmark comparison';
}
plan tests => 1;

###############################################################################
# get the list of JS files we're going to run through testing
# ... but remove "return-regex.js" as JavaScript::Minifier chokes on that one
#     (we're ok in JS:Min:XS, but JS:Min chokes).
my @files = grep { !/return-regex/ } <t/js/*.js>;

###############################################################################
# time test the PurePerl version against the XS version.
compare_benchmark: {
    my $count;
    my $time = 10;
    diag "Benchmarking...";

    # build a longer JavaScript document to process; 64KBytes should be
    # suitable
    my $content = join '', map { slurp($_) } @files;
    my $str = '';
    while (1) {
        last if (length($str) > (64*1024));
        $str .= $content;
    }

    # benchmark the original "pure perl" version
    $count = countit( $time, sub { JavaScript::Minifier::minify(input=>$str) } );
    my $rate_pp = ($count->iters() / $time) * length($str);
    diag "\tperl\t=> $rate_pp bytes/sec";

    # benchmark the "XS" version
    $count = countit( $time, sub { JavaScript::Minifier::XS::minify($str) } );
    my $rate_xs = ($count->iters() / $time) * length($str);
    diag "\txs\t=> $rate_xs bytes/sec";

    pass 'benchmarking';
}




###############################################################################
# HELPER METHOD: slurp in contents of file to scalar.
###############################################################################
sub slurp {
    my $filename = shift;
    my $fin = IO::File->new( $filename, '<' ) || die "can't open '$filename'; $!";
    my $str = join('', <$fin>);
    $fin->close();
    chomp( $str );
    return $str;
}
