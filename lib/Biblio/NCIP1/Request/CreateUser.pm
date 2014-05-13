package Biblio::NCIP1::Request::CreateUser;

use strict;
use warnings;

## We are the lending ILS

use vars qw(@ISA);

@ISA = qw(Biblio::NCIP1::Request);

sub parse_message {
    my ($self, $body) = @_;
    my %user;
    my $created = $body->{MandatedAction}{DateEventOccurred};
    my $nameinfo = $body->{NameInformation};
    my $orgname  = $nameinfo->{OrganizationNameInformation}{OrganizationName};
    my ($last, $first, $name);
    if ($orgname) {
        $user{type} = 'organization';
        $user{last_name} = $orgname;
        $user{first_name} = '';
        $user{name} = $orgname;
        $user{id} = $body->{UniqueUserId}{UserIdentifierValue};
    }
    else {
        die "Can't create a user record for a person";
        # $user{type} = 'person';
        # my $persname = $nameinfo->{PersonalNameInformation};
        # my $last     = $persname->{StructuredPersonalUserName}{Surname};
        # my $first    = $persname->{StructuredPersonalUserName}{GivenName};
        # my $name     = $persname->{UnstructuredPersonalUserName};
        # if (defined $first && defined $last) {
        #     $user{last_name} = $last;
        #     $user{first_name} = $first;
        #     $user{name} = $name || "$first $last";
        # }
        # elsif (defined $name) {
        #     my @parts = split / +/, $name;
        #     $user{last_name} = pop @parts;
        #     $user{first_name} = join(' ', @parts);
        #     $user{name} = $name;
        # }
    }
    my $addrinfo = $body->{UserAddressInformation} || [];
    if (!ref($addrinfo) || ref($addrinfo) eq 'HASH') {
        $addrinfo = [ $addrinfo ];
    }
    foreach my $addr (@$addrinfo) {
        my $phys = $addr->{PhysicalAddress}{StructuredAddress};
        my $elec = $addr->{ElectronicAddress};
        if ($phys) {
            $user{address_line1} = $phys->{Line1}      || '';
            $user{address_line2} = $phys->{Line2}      || '';
            $user{address_city}  = $phys->{Locality}   || '';
            $user{address_state} = $phys->{Region}     || '';
            $user{address_zip}   = $phys->{PostalCode} || '';
        }
        elsif ($elec) {
            my $type = $elec->{ElectronicAddressType}{Value};
            my $val = $elec->{ElectronicAddressData};
            if (defined $val && defined $type) {
                if ($type eq 'tel') {
                    $user{phone} = $val;
                }
                elsif ($type eq 'mailto') {
                    $user{email} = $val;
                }
            }
        }
    }
    if ($created) {
        $self->{retroactive} = 1;
        $self->{created} = $created;
        # XXX
    }
    $self->{user} = \%user;
}

sub build_response {
    my ($self, $result, $body) = @_;
    my $user = $result->{user};
    my $agency = $user->{agency};
    my %uid = ( UniqueUserId => $user->{id} );
    my %agency;
    %agency = (
        UniqueAgencyId => {
            Scheme => $agency->{scheme},
            Value => $agency->{value},
        }
    ) if $agency;
    $body->{UniqueUserId} = { %agency, %uid };
}

1;

