package WebService::Wedata;

use warnings;
use strict;
use Carp;
use LWP::UserAgent;
use JSON::XS;
use WebService::Wedata::Database;

use Data::Dumper;


use version; 
our $VERSION = qv('0.0.3');
our $URL_BASE = 'http://wedata.net';

sub new {
    my($class, $api_key) = @_;
    bless {
        ua => LWP::UserAgent->new,
        api_key => $api_key,
    }, $class;
}

sub get_databases {
    my($self) = @_;
    $self->get_database;
}

sub get_database {
    my($self, $dbname, $page) = @_;
    my $path = ($dbname) ? "/databases/$dbname.json" : '/databases.json';
    $page ||= '';
    my $url = $URL_BASE . $path;
    my $response = $self->{ua}->get($url, page => $page);
    if ($response->is_success) {
        my $data = decode_json($response->content);
        my $parse_response = sub {
            my($data) = @_;
            my @required_keys = split / /, $data->{required_keys};
            my @optional_keys = (defined $data->{optional_keys}) ? split / /, $data->{optional_keys} : ();
            my $database = WebService::Wedata::Database->new(
                ua => $self->{ua},
                api_key => $self->{api_key},
                name => $data->{name},
                description => $data->{description},
                resource_url => $data->{resource_url},
                required_keys => [@required_keys],
                optional_keys => [@optional_keys],
                permit_other_keys => $data->{permit_other_keys},
            );
            $database;
        };
        if ($dbname) {
            $parse_response->($data);
        }
        else {
            my $result = [];
            foreach my $db (@$data) {
                push @$result, $parse_response->($db);
            }
            $result;
        }
    }
    else {
        #FIXME
        carp 'Faild to get_database' . $response->status_line;
        return;
    }
}

sub create_database {
    my($self, @params) = @_;
    my $params = {@params};
    croak "require name on create_database\n" unless $params->{name};

    my $param_required_keys = join '%20', @{$params->{required_keys}};
    my $param_optional_keys = join '%20', @{$params->{optional_keys}};
    my $param_permit_other_keys = ($params->{permit_other_keys}) ? 'true' : 'false';

    my $url = $URL_BASE . '/databases';
    my $content = '';
    $content = join '&',
        "api_key=$self->{api_key}",
        "database[name]=$params->{name}",
        "database[description]=$params->{description}",
        "database[required_keys]=$param_required_keys",
        "database[optional_keys=$param_optional_keys",
        "database[permit_other_keys]=$param_permit_other_keys"
    ;
    my $req = HTTP::Request->new(
        POST => $url,
        HTTP::Headers->new(
            'content-type' => 'application/x-www-form-urlencoded',
            'content-length' => length($content),
        ),
        $content,
    );

    my $response = $self->{ua}->request($req);
    if ($response->is_success) {
        my $database = WebService::Wedata::Database->new(
            ua => $self->{ua},
            api_key => $self->{api_key},
            name => $params->{name},
            description => $params->{description},
            required_keys => $params->{required_keys},
            optional_keys => $params->{optional_keys},
            permit_other_keys => $params->{permit_other_keys},
            resource_url => $response->header('location'),
        );
        $database;
    }
    else {
        print "ERRORRRRRRRRRRRRRRRRRRR\n";
        print Dumper $response;
        croak $response->status_line;
    }
}

sub update_database {
    my($self, @params) = @_;
    my $params = {@params};
    croak "require name on create_database\n" unless $params->{name};

    $params->{api_key} = $self->{api_key};
    $params->{resource_url} = $URL_BASE . '/databases/' . $params->{name};
    my $req = WebService::Wedata::Database::_make_update_request($params);

    my $response = $self->{ua}->request($req);
    if ($response->is_success) {
        $self->get_database($params->{name});
    }
    else {
        print "ERRORRRRRRRRRRRRRRRRRRR\n";
        print Dumper $response;
        croak $response->status_line;
    }
}

sub delete_database {
    my($self, @params) = @_;
    my $params = {@params};
    croak "require name on create_database\n" unless $params->{name};

    $params->{api_key} = $self->{api_key};
    my $req = WebService::Wedata::Database::_make_delete_request($params);
    my $response = $self->{ua}->request($req);
    if ($response->is_success) {
        return;
    }
    else {
        # FIXME
        print "ERRORRRRRRRRRRRRRRRRRRR\n";
        print Dumper $response;
        croak $response->status_line;
    }
}


1; # Magic true value required at end of module
__END__

=head1 NAME

WebService::Wedata - Perl Interface for wedata.net


=head1 VERSION

This document describes WebService::Wedata version 0.0.1


=head1 SYNOPSIS

    use WebService::Wedata;
    
    my $wedata = WebService::Wedata->new('YOUR_API_KEY');
    my $database = $wedata->create_database({
        name => 'database_name',
        required_keys => [qw/foo bar baz/],
        optional_keys => [qw/hoge fuga/],
        permit_other_keys => 'true,'
    });
    
    my $item = $database->create_item({
        name => 'item_name',
        data => {
            foo => 'foo_value',
            bar => 'bar_value',
            baz => 'baz_value',
        }
    });
    my $item = $database->update_item({
        id => 10,
        data => {
            foo => 'foo_updated_value',
            bar => 'bar_updated_value',
            baz => 'baz_updated_value',
        }
    });
    
    $database->delete_item({id => 10});
    $wedata->delete_database('database_name');
  
=head1 DESCRIPTION

Perl Interface for wedata.net

=head1 INTERFACE 

=head2 new

=head2 get_databases

=head2 get_database

=head2 create_database

=head2 update_database

=head2 delete_database


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 DEPENDENCIES

JSON::XS


=head1 AUTHOR

Tsutomu KOYACHI  C<< <rtk2106@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Tsutomu KOYACHI C<< <rtk2106@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.