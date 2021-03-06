package Biblio::NCIP1::Request::CancelRequestItem;

## We are the lending ILS

use strict;
use warnings;

use Biblio::NCIP1::Constants qw(:requests);

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

sub parse_message {
    my ($self, $body) = @_;
    $self->{user}    = $self->user($body);
    $self->{item}    = $self->item($body);
    $self->{request} = $self->request($body);
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
}

1;
