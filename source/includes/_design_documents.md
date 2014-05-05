# Design Documents

Design documents are [documents](#documents) whose `_id`s begin with `_design/`. This causes Cloudant to read certain fields and values of the document as functions, which it uses to [build indexes](#indexes), [validate updates](#update-validators), and [format query results](#list-functions), to name a few uses.

## Indexes

All queries, whether [Search](#search), [MapReduce](#mapreduce), or [Geo](#geo), operate on pre-defined indexes defined in design documents. For more information, see the section for each kind of index:

* [Search](#search)
* [MapReduce](#mapreduce)
* [Geo](#geo)

## List Functions

List functions customize the format of [MapReduce](#mapreduce) query results.

List functions receive two arguments: `head` and `req`.

Once you've defined a list function, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT/_list/$LIST_FUNCTION/$MAPREDUCE_INDEX`, where `$LIST_FUNCTION` is the function's name, and `$MAPREDUCE_INDEX` is the name of the index whose query results you want to format. This request takes the same query parameters as a regular [MapReduce query](#queries53).

### head

Field | Description
------|-------------
total_rows | Number of documents in the view
offset | Offset where the document list started

### req

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

### Built-in Functions

TODO

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

```javascript
function (head, req){
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
TODO
```

```python
TODO
```

```node.js
TODO
```

## Show Functions

Show functions are like [list functions](#list-functions) but for formatting individual documents.

Show functions receive two arguments: `doc`, and `req`. `doc` is the document requested by the show function

> Design doc with a show function:

```json
```

> Example show function:

```javascript
function(doc, req){
  if (doc) {
    return "Hello from " + doc._id + "!";
  } else {
    return "Hello, world!";
  }
}
```

## Update Handlers

TODO

## Filter Functions

TODO

## Update Validators

TODO
