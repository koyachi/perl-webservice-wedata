use Test::More tests => 39;
use WebService::Wedata;
use Data::Dumper;

########################################
# new
# need api_key
eval { my $wedata = WebService::Wedata->new; };
if ($@) {
    # ok 
}
else {
    # ng
}


