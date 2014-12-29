## Creating Views

Views are used to obtain data stored within a database.
Views are written using Javascript functions.

### View concepts

Views are mechanisms for working with document content in databases.
A view can selectively filter documents.
It can speed up searching for content.
It can be used to 'pre-process' the results before they are returned to the client.

Views are simply Javascript functions,
defined within the view field of a design document.
When you use a view,
or more accurately when make a query using your view,
the system applies the Javascript function to each and every document in the database.
Views can be complex.
You might choose to define a collection of Javascript functions to create the overall view required.

### A simple view

> Example of a simple view, using a map function:

```
function(employee) {
  if(employee.training) {
    emit(employee.number, employee.training);
  }
}
```

> Simplified example data:

```json
{
  "_id":"23598567",
  "number":"23598567",
  "training":"2014/05/21 10:00:00"
}

{
  "_id":"10278947",
  "number":"10278947"
}

{
  "_id":"23598567",
  "number":"23598567",
  "training":"2014/07/30 12:00:00"
}
```

> Example response from running the view query

```json
{
  "total_rows": 2,
  "offset": 0,
  "rows": [
    {
      "id":"23598567",
      "number":"23598567",
      "training":"2014/05/21 10:00:00"
    },

    {
      "id":"23598567",
      "number":"23598567",
      "training":"2014/07/30 12:00:00"
    }

  ]
}
```

The simplest form of view is a map function.
The map function produces output data that represents an analysis (a mapping) of the documents stored within the database.

For example,
you might want to find out which employees have had some safety training,
and the date when that training was completed.
You could do this by inspecting each document,
looking for a field in the document called "training".
If the field is present,
the employee completed the training on the date recorded as the value.
If the field is not present,
the employee has not completed the training.

Using the `emit` function in the example view function makes it easy to produce a list in response to running a query using the view.
The list consists of key and value pairs,
where the key helps you identify the specific document and the value provides just the precise detail you want.
The list also includes metadata such as the number of key:value pairs returned.

<aside class="notice">The document `_id` is automatically included in each of the key:value pair result records.
This is to make it easier for the client to work with the results.</aside>

### Map function examples

#### Indexing a field

> Example of indexing a field:

```
function(doc) {
  if (doc.foo) {
    emit(doc._id, doc.foo);
  }
}
```

This map function checks whether the object has a `foo` field and emits the value of this field. This allows you to query against the value of the foo field.

#### An index for a one to many relationship

> Example of indexing a one to many relationship:

```
function(doc) {
  if (doc.friends) {
    for (friend in friends) {
      emit(doc._id, { "_id": friend });
    }
  }
}
```

If the object passed to `emit` has an `_id` field, a view query with `include_docs` set to `true` will contain the document with the given ID.

#### Complex Keys

Keys are not limited to simple values. You can use arbitrary JSON values to influence sorting.

When the key is an array, view results can be grouped by a sub-section of the key. For example, if keys have the form [year, month, day] then results can be reduced to a single value or by year, month, or day. See HttpViewApi for more information. 

### Reduce functions

> Example of a reduce function:

```
function (key, values, rereduce) {
  return sum(values);
}
```

If a view has a reduce function, it is used to produce aggregate results for that view. A reduce function is passed a set of intermediate values and combines them to a single value. Reduce functions must accept, as input, results emitted by its corresponding map function '''as well as results returned by the reduce function itself'''. The latter case is referred to as a ''rereduce''.

Reduce functions are passed three arguments in the order ''key'', ''values'', and ''rereduce''.

Reduce functions must handle two cases:

1.  When `rereduce` is false:

-   `key` will be an array whose elements are arrays of the form `[key,id]`, where `key` is a key emitted by the map function and ''id'' is that of the document from which the key was generated.
-   `values` will be an array of the values emitted for the respective elements in `keys`
-   i.e. `reduce([ [key1,id1], [key2,id2], [key3,id3] ], [value1,value2,value3], false)`

2.  When `rereduce` is true:

-   `key` will be `null`.
-   `values` will be an array of values returned by previous calls to the reduce function.
-   i.e. `reduce(null, [intermediate1,intermediate2,intermediate3], true)`\`

Reduce functions should return a single value, suitable for both the ''value'' field of the final view and as a member of the ''values'' array passed to the reduce function.

Often, reduce functions can be written to handle rereduce calls without any extra code, like the summation function above. In that case, the ''rereduce'' argument can be ignored.

#### Built-in reduce functions

For performance reasons, a few simple reduce functions are built in. To use one of the built-in functions, put its name into the `reduce` field of the view object in your design document.

<table>
<colgroup>
<col width="11%" />
<col width="88%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Function</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>_sum</code></td>
<td align="left">Produces the sum of all values for a key, values must be numeric</td>
</tr>
<tr class="even">
<td align="left"><code>_count</code></td>
<td align="left">Produces the row count for a given key, values can be any valid json</td>
</tr>
<tr class="odd">
<td align="left"><code>_stats</code></td>
<td align="left">Produces a json structure containing sum, count, min, max and sum squared, values must be numeric</td>
</tr>
</tbody>
</table>

By feeding the results of `reduce` functions back into the `reduce` function, MapReduce is able to split up the analysis of huge datasets into discrete, parallelized tasks, which can be completed much faster.

### Dbcopy

If the `dbcopy` field of a view is set, the view contents will be written to a database of that name. If `dbcopy` is set, the view must also have a reduce function. For every key/value pair created by a reduce query with `group` set to `true`, a document will be created in the dbcopy database. If the database does not exist, it will be created. The documents created have the following fields:

<table>
<colgroup>
<col width="18%" />
<col width="81%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Field</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>key</code></td>
<td align="left">The key of the view result. This can be a string or an array.</td>
</tr>
<tr class="even">
<td align="left"><code>value</code></td>
<td align="left">The value calculated by the reduce function.</td>
</tr>
<tr class="odd">
<td align="left"><code>_id</code></td>
<td align="left">The ID is a hash of the key.</td>
</tr>
<tr class="even">
<td align="left"><code>salt</code></td>
<td align="left">This value is an implementation detail used internally.</td>
</tr>
<tr class="odd">
<td align="left"><code>partials</code></td>
<td align="left">This value is an implementation detail used internally.</td>
</tr>
</tbody>
</table>

<aside>
Dbcopy should be used carefully, since it can negatively impact the performance of a database cluster.

 1. It creates a new database, so it can use a lot of disk space.
 2. Dbcopy can also be IO intensive, and building a dbcopy target can adversely affect the rest of the cluster.
 3. It can behave in some unexpected ways. Notably, if a design document with a dbcopy target is created, and the target database has been built, editing this design document so that some documents, which were previously copied, are no longer copied, does not lead to those documents being deleted from the target database. This behavior differs from that of normal views. 

</aside>

### Storing the view definition

> Example for `PUT`ting a view into a design document (`training`):

```http
PUT /$DATABASE/_design/training HTTP/1.1
Content-Type: application/json
```

```shell
curl -X PUT https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/$DATABASE/_design/training --data-binary @view.def
# where the design document is stored in the file `view.def`
```

> Example format for the view:

```json
{
  "views" : {
    "hadtraining" : {
      "map" : "function(employee) { if(employee.training) { emit(employee.number, employee.training); } }"
    }
  }
}
```

Each view is a Javascript function.
Views are stored in design documents.
So,
to store a view,
we simply store the function definition within a design document. A design document can be [created or updated just like any other document](#update).   

Do this by `PUT`ting the view definition content into a `_design` document.
In this example,
the `hadtraining` view is defined as a map function,
and is available within the `views` field of the design document.
