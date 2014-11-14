## MapReduce Views

> Example design document with a single MapReduce index:

```json
{
  "_id": "_design/name",
  "views": {
    "VIEW_NAME": {
      "map":"function(doc){ emit(doc.field, 1); }",
      "reduce": "_sum"
    }
  }
}
```

> Example mapreduce index:

```json
{
  "map": "function (doc) {
    if (doc.kingdom === 'animal') {
        emit(doc.order, doc.species);
      }
    }",
  "reduce": "_count"
}
```

MapReduce is a process for querying data sets. MapReduce views, also known as "CouchDB views" or just "views", are composed of a `map` function that returns specified information from your documents, and an optional `reduce` function that combines those results into a single value.

MapReduce indexes are used for extracting data and presenting it in a specific order, building efficient indexes to find documents by any value or structure within them, and representing relationships among documents with these indexes. 

### Map functions

```
function(doc) {
  emit(doc._id, doc);
}
```

The function contained in the map field is a Javascript function that is called for each document in the database. The map function takes the document as an argument and optionally calls the `emit` function one or more times to emit pairs of keys and values. The simplest example of a map function is this:

The result will be that the view contains every document with the key being the id of the document, effectively creating a copy of the database.

#### Indexing a field

```
function(doc) {
  if (doc.foo) {
    emit(doc._id, doc.foo);
  }
}
```

This map function checks whether the object has a `foo` field and emits the value of this field. This allows you to query against the value of the foo field.

#### An index for a one to many relationship

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

```
function (key, values, rereduce) {
  return sum(values);
}
```

If a view has a reduce function, it is used to produce aggregate results for that view. A reduce function is passed a set of intermediate values and combines them to a single value. Reduce functions must accept, as input, results emitted by its corresponding map function '''as well as results returned by the reduce function itself'''. The latter case is referred to as a ''rereduce''.

Here is an example of a reduce function:

Reduce functions are passed three arguments in the order ''key'', ''values'', and ''rereduce''.

Reduce functions must handle two cases:

1.  When `rereduce` is false:

-   `key` will be an array whose elements are arrays of the form `[key,id]`, where `key` is a key emitted by the map function and ''id'' is that of the document from which the key was generated.
-   `values` will be an array of the values emitted for the respective elements in `keys`
-   i.e. `reduce([ [key1,id1], [key2,id2], [key3,id3] ], [value1,value2,value3], false)`

1.  When `rereduce` is true:

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


