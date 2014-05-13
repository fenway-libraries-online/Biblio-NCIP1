package Biblio::NCIP1::Request::LookupUser;

use strict;
use warnings;

## We are the borrowing *or* lending ILS

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

use constant TYPE_MULTIPURPOSE_ADDRESS => {
    Scheme => 'http://www.niso.org/ncip/v1_0/imp1/schemes/useraddressroletype/useraddressroletype.scm',
    Value  => 'Multi-Purpose',
};

use constant TYPE_STREET_ADDRESS => {
    Scheme => 'http://www.niso.org/ncip/v1_0/imp1/schemes/physicaladdresstype/physicaladdresstype.scm',
    Value  => 'Street Address',
};

use constant TYPE_PHONE_NUMBER => {
    Scheme => 'http://www.iana.org/assignments/uri-schemes.html',
    Value  => 'tel',
};

use constant TYPE_EMAIL_ADDRESS => {
    Scheme => 'http://www.iana.org/assignments/uri-schemes.html',
    Value  => 'mailto',
};

sub parse_message {
    my ($self, $body) = @_;
    $self->{user} = $self->user($body);
}

sub build_response {
    my ($self, $result, $body) = @_;
    my $user = $result->{user};
    my $agency = $user->{agency} || $self->{to};
    my %uid = ( UserIdentifierValue => $user->{barcode} );
    my %agency;
    %agency = (
        UniqueAgencyId => {
            Scheme => $agency->{scheme},
            Value => $agency->{value},
        }
    ) if $agency;
    $body->{UniqueUserId} = { %agency, %uid };
    # Return any other information asked for
    my %fields;
    my ($last, $first, $name, $address, $phone, $email) = @$user{qw(last first name address phone email)};
    if ($name) {
        $fields{NameInformation} = { 
            PersonalNameInformation => {
                UnstructuredPersonalUserName => $name,
                StructuredPersonalUserName => {
                    optional(GivenName => $first),
                    optional(Surname   => $last ),
                },
            },
        };
    }
    my @addresses;
    if ($address) {
        push @addresses, {
            UserAddressRoleType => TYPE_MULTIPURPOSE_ADDRESS,
            PhysicalAddress => {
                PhysicalAddressType => TYPE_STREET_ADDRESS,
                StructuredAddress => {
                    optional(Line1    => $address->{line1}),
                    optional(Line2    => $address->{line2}),
                    optional(Locality => $address->{city} ),
                    optional(Region   => $address->{state}),
                },
            },
        };
    }
    if ($email) {
        push @addresses, {
            UserAddressRoleType => TYPE_MULTIPURPOSE_ADDRESS,
            ElectronicAddress => {
                ElectronicAddressType => TYPE_EMAIL_ADDRESS,
                ElectronicAddressData => $email,
            }
        };
    }
    if ($phone) {
        push @addresses, {
            UserAddressRoleType => TYPE_MULTIPURPOSE_ADDRESS,
            ElectronicAddress => {
                ElectronicAddressType => TYPE_PHONE_NUMBER,
                ElectronicAddressData => $phone,
            }
        };
    }
    $fields{UserAddressInformation} = \@addresses if @addresses;
    $body->{UserOptionalFields} = \%fields;
}

sub optional {
    my ($k, $v) = @_;
    return if !defined $v;
    return ($k => $v);
}

1;
