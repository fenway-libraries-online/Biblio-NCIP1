package Biblio::NCIP1::Request::AcceptItem;

use strict;
use warnings;

## We are the borrowing ILS

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

sub parse_message {
    my ($self, $body) = @_;
    $self->{user} = $self->user($body);
    $self->{item} = $self->item($body);
    $self->{request} = $self->request($body);
    $self->{requested_action_type} = $self->requested_action_type($body);
    my $opt = $body->{ItemOptionalFields};
    $self->{bibdesc}  = $self->bib_description($opt);
    $self->{itemdesc} = $self->item_description($opt);
}

sub build_response {
    my ($self, $result, $body) = @_;
    my $item = $result->{item};
    my $agency = $item->{agency} || $self->{to};
    my %iid = ( ItemIdentifierValue => $item->{barcode} );
    my %rid = ( RequestIdentifierValue => $result->{request}{id} );
    my %agency;
    %agency = (
        UniqueAgencyId => {
            Scheme => $agency->{scheme},
            Value => $agency->{value},
        }
    ) if $agency;
    my $user = $result->{user};
    my %uid = ( UserIdentifierValue => $user->{barcode} );
    $body->{UniqueUserId} = { %agency, %uid };
    $body->{UniqueItemId} = { %agency, %iid };
    $body->{UniqueRequestId} = { %agency, %rid };
}

1;
