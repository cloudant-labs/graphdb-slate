# Attachments

Attachments are [blob](http://en.wikipedia.org/wiki/Binary_large_object) files contained within documents. All attachments have a name and a content type, corresponding to a [MIME type][mime]. If you need to store raw files, use attachments.

## Create / Update

```shell
TODO
```

```python
TODO
```

> Example response:

```json
{
  "id" : "FishStew",
  "ok" : true,
  "rev" : "9-247bb19a41bfd9bfdaf5ee6e2e05be74"
}
```

To create or update an attachment, make a PUT request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC/$ATTACHMENT` where `$ATTACHMENT` is the name of the attachment, and the `rev` query argument is the document's latest revision. The attachment's [content type][mime] must be specified using the `Content-Type` header.

## Read

```shell
TODO
```

```python
TODO
```

To retrieve a document, make a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC/$ATTACHMENT`. The body of the response will be the raw blob file.

## Delete

```shell
TODO
```

```python
TODO
```

> Example response:

```json
{
  "ok": true,
  "id": "DocID",
  "rev": "3-aedfb06537c1d77a087eb295571f7fc9"
}
```

To delete a document, make a DELETE request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC/$ATTACHMENT`, where the `rev` query argument is the document's latest revision. If the revision is not provided or is not the document's latest, Cloudant will respond with a 409 error.

[mime]: http://en.wikipedia.org/wiki/Internet_media_type#List_of_common_media_types