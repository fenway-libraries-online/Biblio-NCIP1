package Biblio::NCIP1::Constants;

BEGIN {
    require Exporter;
    use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
    @ISA = 'Exporter';
}

use Package::Constants;

my @constants = @EXPORT_OK = Package::Constants->list( __PACKAGE__ );

%EXPORT_TAGS = (
    'all'      => \@constants,
    'requests' => [ grep { /^REQ_/   } @constants ],
    'users'    => [ grep { /^USER_/  } @constants ],
    'ncip'     => [ grep { /^NCIP1_/ } @constants ],
    'errors'   => [ grep { /^ERR_/   } @constants ],
);

use constant NCIP1_DTD     => 'http://www.niso.org/ncip/v1_0/imp1/dtd/ncip_v1_0.dtd';
use constant NCIP1_DOCTYPE => sprintf q{<!DOCTYPE NCIPMessage PUBLIC "-//NISO//NCIP DTD Version 1//EN" "%s">}, NCIP1_DTD;

use constant REQ_SCOPE_SCHEME         => q{http://www.niso.org/ncip/v1_0/imp1/schemes/requestscopetype/requestscopetype.scm};
use constant REQ_SCOPE_VALUE_BIB_ITEM => 'Bibliographic Item';
use constant REQ_SCOPE_VALUE_ITEM     => 'Item';

use constant REQ_TYPE_SCHEME     => q{http://www.niso.org/ncip/v1_0/imp1/schemes/requesttype/requesttype.scm};
use constant REQ_TYPE_VALUE_HOLD => 'Hold';
use constant REQ_TYPE_VALUE_LOAN => 'Loan';

use constant REQ_BIBITEM_IS_BIB  => 'bib';
use constant REQ_BIBITEM_IS_ITEM => 'item';

use constant USER_TYPE_PERSON       => 'person';
use constant USER_TYPE_ORGANIZATION => 'organization';

use constant ERR_AGENCY_AUTHENTICATION_FAILED                          => { 'errtype' => 'General', 'message' =>  'Agency Authentication Failed' };
use constant ERR_INVALID_AMOUNT                                        => { 'errtype' => 'General', 'message' =>  'Invalid Amount' };
use constant ERR_INVALID_DATE                                          => { 'errtype' => 'General', 'message' =>  'Invalid Date' };
use constant ERR_NEEDED_DATA_MISSING                                   => { 'errtype' => 'General', 'message' =>  'Needed Data Missing' };
use constant ERR_SYSTEM_AUTHENTICATION_FAILED                          => { 'errtype' => 'General', 'message' =>  'System Authentication Failed' };
use constant ERR_TEMPORARY_PROCESSING_FAILURE                          => { 'errtype' => 'General', 'message' =>  'Temporary Processing Failure' };
use constant ERR_UNAUTHORIZED_COMBINATION_OF_ELEMENT_VALUES_FOR_AGENCY => { 'errtype' => 'General', 'message' =>  'Unauthorized Combination Of Element Values For Agency' };
use constant ERR_UNAUTHORIZED_COMBINATION_OF_ELEMENT_VALUES_FOR_SYSTEM => { 'errtype' => 'General', 'message' =>  'Unauthorized Combination Of Element Values For System' };
use constant ERR_UNAUTHORIZED_SERVICE_FOR_AGENCY                       => { 'errtype' => 'General', 'message' =>  'Unauthorized Service For Agency' };
use constant ERR_UNAUTHORIZED_SERVICE_FOR_SYSTEM                       => { 'errtype' => 'General', 'message' =>  'Unauthorized Service For System' };
use constant ERR_UNKNOWN_AGENCY                                        => { 'errtype' => 'General', 'message' =>  'Unknown Agency' };
use constant ERR_UNKNOWN_SYSTEM                                        => { 'errtype' => 'General', 'message' =>  'Unknown System' };
use constant ERR_UNSUPPORTED_SERVICE                                   => { 'errtype' => 'General', 'message' =>  'Unsupported Service' };

use constant ERR_ACCOUNT_ACCESS_DENIED                                 => 'Account Access Denied';
use constant ERR_AGENCY_ACCESS_DENIED                                  => 'Agency Access Denied';
use constant ERR_CANNOT_ACCEPT_ITEM                                    => 'Cannot Accept Item';
use constant ERR_CANNOT_GUARANTEE_RESTRICTIONS_ON_USE                  => 'Cannot Guarantee Restrictions on Use';
use constant ERR_DUPLICATE_AGENCY                                      => 'Duplicate Agency';
use constant ERR_DUPLICATE_FISCAL_TRANSACTION                          => 'Duplicate Fiscal Transaction';
use constant ERR_DUPLICATE_ITEM                                        => 'Duplicate Item';
use constant ERR_DUPLICATE_REQUEST                                     => 'Duplicate Request';
use constant ERR_DUPLICATE_USER                                        => 'Duplicate User';
use constant ERR_ELEMENT_RULE_VIOLATED                                 => 'Element Rule Violated';
use constant ERR_INVALID_MESSAGE_SYNTAX_ERROR                          => 'Invalid Message Syntax Error';
use constant ERR_ITEM_ACCESS_DENIED                                    => 'Item Access Denied';
use constant ERR_ITEM_CANNOT_BE_RECALLED                               => 'Item Cannot Be Recalled';
use constant ERR_ITEM_DOES_NOT_CIRCULATE                               => 'Item Does Not Circulate';
use constant ERR_ITEM_NOT_AVAILABLE_BY_NEED_BEFORE_DATE                => 'Item Not Available By Need Before Date';
use constant ERR_ITEM_NOT_CHECKED_OUT                                  => 'Item Not Checked Out';
use constant ERR_ITEM_NOT_CHECKED_OUT_TO_THIS_USER                     => 'Item Not Checked Out To This User';
use constant ERR_ITEM_NOT_RENEWABLE                                    => 'Item Not Renewable';
use constant ERR_MAXIMUM_CHECK_OUTS_EXCEEDED                           => 'Maximum Check Outs Exceeded';
use constant ERR_MAXIMUM_RENEWALS_EXCEEDED                             => 'Maximum Renewals Exceeded';
use constant ERR_NON_UNIQUE_ITEM                                       => 'Non-Unique Item';
use constant ERR_NON_UNIQUE_USER                                       => 'Non-Unique User';
use constant ERR_PROTOCOL_ERROR                                        => 'Protocol Error';
use constant ERR_RECALL_CANNOT_BE_CANCELLED_AT_THIS_TIME               => 'Recall Cannot Be Cancelled At This Time';
use constant ERR_RENEWAL_NOT_ALLOWED_ITEM_HAS_OUTSTANDING_REQUESTS     => 'Renewal Not Allowed - Item Has Outstanding Requests';
use constant ERR_REQUEST_ALREADY_PROCESSED                             => 'Request Already Processed';
use constant ERR_RESOURCE_CANNOT_BE_PROVIDED                           => 'Resource Cannot Be Provided';
use constant ERR_UNABLE_TO_ADD_ELEMENT                                 => 'Unable To Add Element';
use constant ERR_UNABLE_TO_DELETE_ELEMENT                              => 'Unable To Delete Element';
use constant ERR_UNKNOWN_ELEMENT                                       => 'Unknown Element';
use constant ERR_UNKNOWN_ITEM                                          => 'Unknown Item';
use constant ERR_UNKNOWN_REQUEST                                       => 'Unknown Request';
use constant ERR_UNKNOWN_SCHEME                                        => 'Unknown Scheme';
use constant ERR_UNKNOWN_SERVICE                                       => 'Unknown Service';
use constant ERR_UNKNOWN_USER                                          => 'Unknown User';
use constant ERR_UNKNOWN_VALUE_FROM_KNOWN_SCHEME                       => 'Unknown Value From Known Scheme';
use constant ERR_UNSUPPORTED_NOTICE                                    => 'Unsupported Notice';
use constant ERR_UNSUPPORTED_SHIPPING_ADDRESS_TYPE                     => 'Unsupported Shipping Address Type';
use constant ERR_USER_ACCESS_DENIED                                    => 'User Access Denied';
use constant ERR_USER_AUTHENTICATION_FAILED                            => 'User Authentication Failed';
use constant ERR_USER_BLOCKED                                          => 'User Blocked';
use constant ERR_USER_INELIGIBLE_TO_CHECK_OUT_THIS_ITEM                => 'User Ineligible To Check Out This Item';
use constant ERR_USER_INELIGIBLE_TO_RENEW_THIS_ITEM                    => 'User Ineligible To Renew This Item';
use constant ERR_USER_INELIGIBLE_TO_REQUEST_THIS_ITEM                  => 'User Ineligible To Request This Item';

1;
