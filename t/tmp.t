use Test::More qw/no_plan/;
use WebService::Wedata;
use Data::Dumper;

SKIP: {
    skip 'experimental';


my $my_api_key = 'YOUR_API_KEY';
my $wedata = WebService::Wedata->new($my_api_key);

my $database;
my $db_name = 'test_db_from_WebService::Wedata' . time;

########################################
# prepare
$database = $wedata->create_database(
    name => $db_name,
    required_keys => [qw/foo bar baz/],
    optional_keys => [qw/hoge fuga/],
    permit_other_keys => 'true',
);

my $item = $database->create_item(

);

########################################
$item->update(
    data => {
        foo => 1,
        bar => 2,
    }
);

$item->delete;




########################################
$database->update(
    name => $db_name,
    required_keys => [qw/foo_2 bar_2 baz_2/],
    optional_keys => [qw/hoge_2 fuga_2/],
    permit_other_keys => 'true',
);
# check updated database


$database->delete;
# check deleted database

}
