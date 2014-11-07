## Attachments

If you want to store data, use attachments.
Attachments are Binary Large Object ([BLOb](http://en.wikipedia.org/wiki/Binary_large_object)) files contained within documents.
The BLOb is stored in the `_attachments` component of the document.
The BLOb includes data about the attachment name, the type of the attachment, and the actual content represented in BASE64 form.
Examples of BLObs would be images and multimedia.

The content type corresponds to a [MIME type][mime].
For example, if you want to attach a `.jpg` image file to a document,
you would specify the attachment MIME type as `image/jpeg`.

### Create / Update

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT?rev=$REV \
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
    db.attachment.insert($DOCUMENT_ID, $ATTACHMENT, data, $ATTACHMENT_MIME_TYPE, { 
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

To create a new attachment at the same time as creating a new document,
include the attachment as an '[inline](#inline)' component of the JSON content.

To create a new attachment on an existing document,
or to update an attachment on a document,
make a PUT request with the document's latest `_rev` to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT`. 
The attachment's [content type][mime] must be specified using the `Content-Type` header.
The `$ATTACHMENT` value is the name by which the attachment is associated with the document.

<aside>You can create more than one attachment for a document;
simply ensure that the `$ATTACHMENT` value for each attachment is unique with the document.</aside>

### Read

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT \
     -u $USERNAME

curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT \
     -u $USERNAME > blob_content.dat
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.attachment.get($DOCUMENT_ID, $FILENAME, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

To retrieve an attachment,
make a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT`.
The body of the response is the raw content of the attachment.
You might pipe the response content directly into a file, for further processing.

### Delete

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT?rev=$REV \
     -u $USERNAME \
     -X DELETE
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.attachment.destroy($DOCUMENT_ID, $FILENAME, $REV, function (err, body) {
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

To delete an attachment, make a DELETE request with the document's latest `_rev` to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT_ID/$ATTACHMENT`.
If you do not supply the latest `_rev`,
the response is a [409 error](#errors).

### Inline

Inline attachments are attachments included as part of the JSON content.
An example of JSON content that includes an inline attachment of a jpeg image is as follows:

```{
  "_id":"document_with_attachment",
  "_attachments":
  {
    "name_of_attachment":
    {
      "content_type":"image/jpeg",
      "data": "iVBORw0KGgoAA... ...AASUVORK5CYII="
    }
  }
}```

[mime]: http://en.wikipedia.org/wiki/Internet_media_type#List_of_common_media_types
