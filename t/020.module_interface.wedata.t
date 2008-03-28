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

eval { my $wedata = WebService::Wedata->new('hogefuga'); };
if ($@) {
    # ng
}
else {
    # ok
}


########################################
# get_database
# need dbname
eval { my $wedata = WebService::Wedata->get_database; };
if ($@) {
    # ok 
}
else {
    # ng
}

eval { my $wedata = WebService::Wedata->get_database('hogefuga'); };
if ($@) {
    # ng
}
else {
    # ok 
}

eval { my $wedata = WebService::Wedata->get_database('hogefuga', 1); };
if ($@) {
    # ng
}
else {
    # ok 
}


# PREPARE
my $wedata = WebService::Wedata->new('api_key');


########################################
# create_databasae
eval { my $database = $wedata->create_database; };
if ($@) {
    # ok 
}
else {
    # ng
}

# need name
eval { my $database = $wedata->create_database(
    description => 'desc',
    required_keys => [qw/a b/],
    optional_keys => [qw/c d/],
    permit_other_keys => 'false',
); };
if ($@) {
    # ok 
}
else {
    # ng
}

# need required_keys
eval { my $database = $wedata->create_database(
    name => 'name'
    description => 'desc',
    optional_keys => [qw/c d/],
    permit_other_keys => 'false',
); };
if ($@) {
    # ok 
}
else {
    # ng
}

# need permit_other_keys
eval { my $database = $wedata->create_database(
    name => 'name'
    description => 'desc',
    required_keys => [qw/a b/],
    optional_keys => [qw/c d/],
); };
if ($@) {
    # ok 
}
else {
    # ng
}


########################################
# update_database


########################################
# delete_database

