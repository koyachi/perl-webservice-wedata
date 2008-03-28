use Test::More 'no_plan';
use WebService::Wedata;
use LWP::UserAgent;
use Data::Dumper;

SKIP: 
{
    skip 'experimental';

my $ua = LWP::UserAgent->new;
my $params = {
    ua => $ua,
    api_key => 'aaa api key',
    name => 'bbb name',
    description => 'ccc desc',
    resource_url => 'ddd resource_url',
    required_keys => [qw/rk1 rk2 rk3/],
    optional_keys => [qw/ok1 ok2 ok3/],
    permit_other_keys => 'true',
};
my $database = WebService::Wedata::Database->new(%$params);
#print Dumper $database;

$database->description('updated description!');
$database->update;

$database->delete;


}
