use strict;
use warnings;
use Test::More;
use File::Slurp qw(slurp);
use File::Which qw(which);
use Benchmark qw(countit);
use JavaScript::Minifier;
use JavaScript::Minifier::XS;

###############################################################################
# Only run Benchmark if asked for.
unless ($ENV{BENCHMARK}) {
    plan skip_all => 'Skipping Benchmark; use BENCHMARK=1 to run';
}

###############################################################################
# Find "curl"
my $curl = which('curl');
unless ($curl) {
    plan skip_all => 'curl required for comparison';
}

###############################################################################
# What JS files do we want to try compressing?
my @libs = (
    'http://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.js',
    'http://code.jquery.com/jquery-3.5.1.js',
    'http://cdnjs.cloudflare.com/ajax/libs/react/17.0.1/cjs/react.development.js',
);

###############################################################################
# time test the PurePerl version against the XS version.
my $time = 1;
foreach my $uri (@libs) {
    subtest $uri => sub {
        my $content = qx{$curl --silent $uri};
        ok defined $content, 'fetched JS';
        BAIL_OUT("No JS fetched!") unless (length($content));

        # benchmark the original "pure perl" version
        my $count = countit($time, sub { JavaScript::Minifier::minify(input => $content) });
        my $rate_pp = ($count->iters() / $time) * length($content);
        pass "\tperl\t=> $rate_pp bytes/sec";

        # benchmark the "XS" version
        $count = countit( $time, sub { JavaScript::Minifier::XS::minify($content) } );
        my $rate_xs = ($count->iters() / $time) * length($content);
        pass "\txs\t=> $rate_xs bytes/sec";
    };
}

###############################################################################
done_testing();
