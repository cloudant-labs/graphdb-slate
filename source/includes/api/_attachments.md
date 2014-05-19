## Attachments

Attachments are [BLOb](http://en.wikipedia.org/wiki/Binary_large_object) files contained within documents. Examples of BLObs would be images and multimedia. All attachments have a name and a content type, corresponding to a [MIME type][mime]. If you need to store raw files, use attachments.

### Create / Update

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT/$ATTACHMENT?rev=$REV \
     -u $USERNAME \
     -X PUT \
     -H "Content-Type: $ATTACHMENT_MIME_TYPE" \
     --data-binary @$ATTACHMENT_FILEPATH
```

```javascript
var nano = require('nano');
var fs = require('fs');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

fs.readFile($FILEPATH, function (err, data) {
  if (!err) {
    db.attachment.insert($DOCUMENT, $ATTACHMENT, data, $ATTACHMENT_MIME_TYPE, { 
      rev: $REV
    }, function (err, body) {
      if (!err)
        console.log(body);
    });
  }
});
```

> Example response:

```json
{
  "id" : "FishStew",
  "ok" : true,
  "rev" : "9-247bb19a41bfd9bfdaf5ee6e2e05be74"
}
```

To create or update an attachment, make a PUT request with the attachment's latest `_rev` to `https://$USERNAME.cloudant.com/$DATABASE/$_ID/$ATTACHMENT`.  The attachment's [content type][mime] must be specified using the `Content-Type` header.

### Read

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT/$ATTACHMENT \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.attachment.get($DOCUMENT, $FILENAME, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

To retrieve a document, make a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$_ID/$ATTACHMENT`. The body of the response will be the raw blob file.

### Delete

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT/$ATTACHMENT?rev=$REV \
     -u $USERNAME \
     -X DELETE
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.attachment.destroy($DOCUMENT, $FILENAME, $REV, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
  "ok": true,
  "id": "DocID",
  "rev": "3-aedfb06537c1d77a087eb295571f7fc9"
}
```

To delete a document, make a DELETE request with the document's latest `_rev` to `https://$USERNAME.cloudant.com/$DATABASE/$_ID/$ATTACHMENT`. Anything but the latest `_rev` will return a [409 error](#errors).

[mime]: http://en.wikipedia.org/wiki/Internet_media_type#List_of_common_media_types
