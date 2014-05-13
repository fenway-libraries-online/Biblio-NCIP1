package Biblio::NCIP1::Request::CheckInItem;

use strict;
use warnings;

## We are the borrowing *or* lending ILS

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

sub parse_message {
    my ($self, $body) = @_;
    $self->{item} = $self->item($body);
}

sub build_response {
    my ($self, $result, $body) = @_;
    my $item = $result->{item};
    my $agency = $item->{agency} || $self->{to};
    my %iid = ( ItemIdentifierValue => $item->{barcode} );
    my %agency;
    %agency = (
        UniqueAgencyId => {
            Scheme => $agency->{scheme},
            Value => $agency->{value},
        }
    ) if $agency;
    $body->{UniqueItemId} = { %agency, %iid };
    # $body->{UniqueRequestId} = $self->{request};
}

1;
