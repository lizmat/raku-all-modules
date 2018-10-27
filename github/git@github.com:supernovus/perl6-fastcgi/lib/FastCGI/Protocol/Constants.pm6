use v6;

unit module FastCGI::Protocol::Constants;

#### Protocol constants.

## Common
constant FCGI_LISTENSOCK_FILENO is export(:common) = 0;
constant FCGI_MAX_CONTENT_LEN   is export(:common) = 0xFFFF;
constant FCGI_HEADER_LEN        is export(:common) = 8;
constant FCGI_VERSION_1         is export(:common) = 1;
constant FCGI_NULL_REQUEST_ID   is export(:common) = 0;
constant FCGI_SEGMENT_LEN       is export(:common) = 32768 - FCGI_HEADER_LEN;

## Type
constant FCGI_BEGIN_REQUEST     is export(:type) = 1;
constant FCGI_ABORT_REQUEST     is export(:type) = 2;
constant FCGI_END_REQUEST       is export(:type) = 3;
constant FCGI_PARAMS            is export(:type) = 4;
constant FCGI_STDIN             is export(:type) = 5;
constant FCGI_STDOUT            is export(:type) = 6;
constant FCGI_STDERR            is export(:type) = 7;
constant FCGI_DATA              is export(:type) = 8;
constant FCGI_GET_VALUES        is export(:type) = 9;
constant FCGI_GET_VALUES_RESULT is export(:type) = 10;
constant FCGI_UNKNOWN_TYPE      is export(:type) = 11;
constant FCGI_MAXTYPE           is export(:type) = FCGI_UNKNOWN_TYPE;

## Role
constant FCGI_RESPONDER   is export(:role) = 1;
constant FCGI_AUTHORIZER  is export(:role) = 2;
constant FCGI_FILTER      is export(:role) = 3;

## Flag
constant FCGI_KEEP_CONN is export(:flag) = 1;

## Protocol status
constant FCGI_REQUEST_COMPLETE is export(:protocol_status) = 0;
constant FCGI_CANT_MPX_CONN    is export(:protocol_status) = 1;
constant FCGI_OVERLOADED       is export(:protocol_status) = 2;
constant FCGI_UNKNOWN_ROLE     is export(:protocol_status) = 3;

## Value
constant FCGI_MAX_CONNS   is export(:value) = 'FCGI_MAX_CONNS';
constant FCGI_MAX_REQS    is export(:value) = 'FCGI_MAX_REQS';
constant FCGI_MPXS_CONNS  is export(:value) = 'FCGI_MPXS_CONNS';

## Pack and unpack formats.
constant FCGI_Header_P           is export(:pack) = 'CCnnCx';
constant FCGI_Header_U           is export(:pack) = 'xCnnCx';
constant FCGI_BeginRequestBody   is export(:pack) = 'nCx5';
constant FCGI_EndRequestBody     is export(:pack) = 'NCx3';
constant FCGI_UnknownTypeBody    is export(:pack) = 'Cx7';
constant FCGI_GetRecordLength    is export(:pack) = 'xxxnCx';

## Record names
constant FCGI_RecordNames is export(:type) = 
[
  '',
  'FCGI_BeginRequestRecord',
  'FCGI_AbortRequestRecord',
  'FCGI_EndRequestRecord',
  'FCGI_ParamsRecord',
  'FCGI_StdinRecord',
  'FCGI_StdoutRecord',
  'FCGI_StderrRecord',
  'FCGI_DataRecord',
  'FCGI_GetValuesRecord',
  'FCGI_GetValuesResultRecord',
  'FCGI_UnknownTypeRecord',
];

## Type names
constant FCGI_TypeNames is export(:type) =
[
  '',
  'FCGI_BEGIN_REQUEST',
  'FCGI_ABORT_REQUEST',
  'FCGI_END_REQUEST',
  'FCGI_PARAMS',
  'FCGI_STDIN',
  'FCGI_STDOUT',
  'FCGI_STDERR',
  'FCGI_DATA',
  'FCGI_GET_VALUES',
  'FCGI_GET_VALUES_RESULT',
  'FCGI_UNKNOWN_TYPE',
];

## Role names
constant FCGI_RoleNames is export(:role) =
[
  '',
  'FCGI_RESPONDER',
  'FCGI_AUTHORIZER',
  'FCGI_FILTER',
];

## Protocol status names
constant FCGI_ProtocolStatusNames is export(:protocol_status) =
[
  'FCGI_REQUEST_COMPLETE',
  'FCGI_CANT_MPX_CONN',
  'FCGI_OVERLOADED',
  'FCGI_UNKNOWN_ROLE',
];

