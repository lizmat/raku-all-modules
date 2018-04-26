use v6.c;
use Test;
use YAMLish;
use OpenAPI::Model;

my $yaml = q:to/END/;
content:
  multipart/mixed:
    schema:
      type: object
      properties:
        id:
          # default is text/plain
          type: string
          format: uuid
        address:
          # default is application/json
          type: object
          properties: {}
        historyMetadata:
          # need to declare XML format!
          description: metadata in XML format
          type: object
          properties: {}
        profileImage:
          # default is application/octet-stream, need to declare an image type only!
          type: string
          format: binary
    encoding:
      historyMetadata:
        # require XML Content-Type in utf-8 encoding
        contentType: application/xml; charset=utf-8
      profileImage:
        # only accept png/jpeg
        contentType: image/png, image/jpeg
        headers:
          X-Rate-Limit-Limit:
            description: The number of allowed requests in the current period
            schema:
              type: integer
END

my $api;

lives-ok { $api = OpenAPI::Model::RequestBody.deserialize(load-yaml($yaml), OpenAPI::Model.new) }, 'Can parse request body';

is $api.content<multipart/mixed>.encoding<historyMetadata>.content-type, 'application/xml; charset=utf-8', 'Check Content-Type of content';

is $api.content<multipart/mixed>.encoding<profileImage>.headers<X-Rate-Limit-Limit>.description, 'The number of allowed requests in the current period', 'Check header description of encoding';

done-testing;
