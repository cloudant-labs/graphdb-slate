## Design Documents

Design documents are [documents](#documents) whose `_id`s begin with `_design/`. Cloudant reads certain fields and values of design documents as functions, which it uses to [build indexes](#indexes), [validate updates](#update-validators), and [format query results](#list-functions).

Since the `$VARIABLES` in these instructions contain both standard and design documents, respective `_id`s are indicated by `$DOC_ID` and `%DESIGN_ID`.

### Indexes

All queries operate on pre-defined indexes defined in design documents. These indexes are:

* [Search](#search)
* [MapReduce](#mapreduce)
* [Geo](#geo)

Because design documents are still [documents](#documents), a [search index](#search) can be added by [updating](#update) the document with the appropriate field or by [inserting](#create29) a new document with it. You can make queries against the index as soon as it's written with the design document.

### List Functions

> Design doc with a list function:

```json
{
  "_id": "_design/list_example",
  "lists": {
    "FUNCTION_NAME": "function (head, req) { ... }"
  }
}
```

> Example list function:

```
function (head, req) {
  // specify our headers
  start({
    headers: {
      "Content-Type": 'text/html'
    }
  });
  // send the respond, line by line
  send('<html><body><table>');
  send('<tr><th>ID</th><th>Key</th><th>Value</th></tr>')
  while(row = getRow()){
    send(''.concat(
      '<tr>',
      '<td>' + toJSON(row.id) + '</td>',
      '<td>' + toJSON(row.key) + '</td>',
      '<td>' + toJSON(row.value) + '</td>',
      '</tr>'
    ));
  }
  send('</table></body></html>');
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_list/$LIST_FUNCTION/$MAPREDUCE_INDEX \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.view_with_list($DESIGN_ID, $MAPREDUCE_INDEX, $LIST_FUNCTION, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

List functions customize the format of [MapReduce](#mapreduce) query results.

List functions receive two arguments: `head` and `req`.

Once you've defined a list function, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_list/$LIST_FUNCTION/$MAPREDUCE_INDEX`, where `$LIST_FUNCTION` is the function's name, and `$MAPREDUCE_INDEX` is the name of the index whose query results you want to format. This request takes the same query parameters as a regular [MapReduce query](#queries53).

#### head

Field | Description
------|-------------
total_rows | Number of documents in the view
offset | Offset where the document list started

#### req

Field | Description
------|-------------
body | Request body data as string. If the request method is GET this field contains the value "undefined". If the method is DELETE or HEAD the value is "" (empty string).
cookie | Cookies object.
form | Form data object. Contains the decoded body as key-value pairs if the Content-Type header was `application/x-www-form-urlencoded`.
headers | Request headers object.
id | Requested document id string if it was specified or null otherwise.
info | Database information
method | Request method as string or array. String value is a method as one of: HEAD, GET, POST, PUT, DELETE, OPTIONS, and TRACE. Otherwise it will be represented as an array of char codes.
path | List of requested path sections.
peer | Request source IP address.
query | URL query parameters object. Note that multiple keys are not supported and the last key value suppresses others.
requested_path | List of actual requested path section.
raw_path | Raw requested path string.
secObj | The database's [security object](#reading-permissions)
userCtx | Context about the currently authenticated user, specifically their `name` and `roles` within the current database.
uuid | A generated UUID

### Show Functions

> Design doc with a show function:

```json
{
  "_id": "_design/show_example",
  "shows": {
    "FUNCTION_NAME": "function (doc, req) { ... }"
  }
}
```

> Example show function:

```
function (doc, req) {
  if (doc) {
    return "Hello from " + doc._id + "!";
  } else {
    return "Hello, world!";
  }
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_show/$SHOW_FUNCTION/$DOCUMENT_ID \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.show($DESIGN_ID, $SHOW_FUNCTION, $DOCUMENT_ID, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

Show functions are like [list functions](#list-functions) but for formatting individual documents.

Show functions receive two arguments: `doc`, and [req](#req). `doc` is the document requested by the show function.

Once you've defined a show function, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOC_ID/_show/$SHOW_FUNCTION/$DESIGN_ID`, where `$SHOW_FUNCTION` is the function's name, and `$DESIGN_ID` is the `_id` of the document you want to run the show function on.

### Update Handlers

> Example design doc:

```json
{
  "_id": "_design/update_example",
  "updates": {
    "UPDATE_HANDLER_NAME": "function (doc, req) { ... }"
  }
}
```

> Example update handler:

```
function(doc, req){
  if (!doc){
    if ('id' in req && req.id){
      // create new document
      return [{_id: req.id}, 'New World']
    }
    // change nothing in database
    return [null, 'Empty World']
  }
  doc.world = 'hello';
  doc.edited_by = req.userCtx.name
  return [doc, 'Edited World!']
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER \
     -X POST \
     -H "Content-Type: application/json" \
     -u $USERNAME
     -d $JSON
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");
var db = account.use($DATABASE);

db.atomic($DESIGN_ID, $UPDATE_HANDLER, $DOCUMENT_ID, $JSON, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

Update handlers are custom functions that live on Cloudant's server that will create or update a document. This can, for example, provide server-side modifcation timestamps, and document updates to individual fields without the latest revision. 

Update handlers receive two arguments: `doc` and [req](#req). If a document ID is provided in the request to the update handler, then `doc` will be the document corresponding with that ID. If no ID was provided, `doc` will be `null`.

Update handler functions must return an array of two elements, the first being the document to save (or null, if you don't want to save anything), and the second being the response body.

Here's how to query update handlers:

Method | URL
-------|------
POST | `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER`
PUT | `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_update/$UPDATE_HANDLER/$DOC_ID`

Where `$DESIGN_ID` is the `_id` of the document defining the update handler, `$UPDATE_HANDLER` is the name of the update handler, and `$DOC_ID` is the `_id` of the document you want the handler to, well, handle.

### Filter Functions

> Example design document:

```json
{
  "_id":"_design/FILTER_EXAMPLE",
  "filters": {
    "FILTER_EXAMPLE": "function (doc, req) { ... }"
  }
}
```

> Example filter function:

```
function(doc, req){
  // we need only `mail` documents
  if (doc.type != 'mail'){
    return false;
  }
  // we're interested only in `new` ones
  if (doc.status != 'new'){
    return false;
  }
  return true; // passed!
}
```

> Example queries:

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_changes?filter=$FILTER \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");

account.db.changes($DATABASE, {
  filter: $FILTER
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

Filter functions format the [changes feed](#list-changes), removing changes you don't want to monitor. The filter function is run over every change in the changes feed, and only those for which the function returns `true` are returned to the client in the response.

Filter functions receive two arguments: `doc` and [req](#req). `doc` represents the document currently being filtered.

To use a filter function on the changes feed, specify the function in the `_changes` query. See the examples for more details.

### Update Validators

> Example design document:

```json
{
  "_id": "_design/validator_example",
  "validate_doc_update": "function(newDoc, oldDoc, userCtx, secObj) { ... }"
}
```

> Example update validator:

```
function(newDoc, oldDoc, userCtx, secObj) {
  if (newDoc.address === undefined) {
     throw({forbidden: 'Document must have an address.'});
  }
}
```

> Example response:

```json
{
  "error": "forbidden",
  "reason": "Document must have an address."
}
```

Update validators evaluate whether a document should be written to disk when insertions and updates are attempted. They do not require a query because they implicitly run during this process. If a change is rejected, the update validator responds with a custom error. 

Update validators get four arguments:

* `newDoc`: the version of the document passed in the request.
* `oldDoc`: the version of the document currently in the database, or `null` if there is none.
* `userCtx`: context about the currently authenticated user, such as `name` and `roles`..
* `secObj`: the database's [security object](#reading-permissions)
