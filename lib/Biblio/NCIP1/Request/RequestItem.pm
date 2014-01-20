package Biblio::NCIP1::Request::RequestItem;

## We are the lending ILS

use strict;
use warnings;

use Biblio::NCIP1::Constants qw(:requests);

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

sub parse_message {
    my ($self, $body) = @_;
    $self->{user}    = $self->user($body);
    $self->{request} = $self->request($body);
    $self->{scope}   = $self->request_scope_type($body);
    $self->{type}    = $self->request_type($body);
    $self->{bibitem} = $self->bibitem($body);
}

sub build_response {
    my ($self, $result, $body) = @_;
    my $user = $result->{user};
    my $item = $result->{item};
    my $agency = $item->{agency} || $self->{to};
    my %uid = ( UserIdentifierValue => $user->{barcode} );
    my %iid = ( ItemIdentifierValue => $item->{barcode} );
    my %agency;
    %agency = (
        UniqueAgencyId => {
            Scheme => $agency->{scheme},
            Value => $agency->{value},
        }
    ) if $agency;
    $body->{UniqueUserId} = { %agency, %uid };
    $body->{UniqueItemId} = { %agency, %iid };
    $body->{RequestType} = {
        Scheme => REQ_TYPE_SCHEME,
        Value => REQ_TYPE_VALUE_HOLD,
    };
    $body->{RequestScopeType} = {
        Scheme => REQ_SCOPE_SCHEME,
        Value => $self->{scope},
    };
}

1;

