## MapReduce

> Example design document:

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

```javascript
{
  map: function (doc) {
    if (doc.kingdom === 'animal') {
      emit(doc.order, doc.species);
    }
  },
  reduce: '_count'
}
```

MapReduce is a process for querying data sets. They're composed of a `map` function that returns specified info from your documents, and a `reduce` function that combines those results into a single value. `emit` is a function within `map` that determines what keys and values to index. 

MapReduce indexes are used for extracting data and presenting it in a specific order, building efficient indexes to find documents by any value or structure within them, and representing relationships among documents with these indexes. 

`map` functions run once for every document in the database, which appear as the `doc` parameter. The optional `reduce` field can be one of the following functions, or a [custom function](#custom-reduces).

Function Name | Description
--------------|-------------
`_sum` | Produces the sum of all values for a key. Values must be numeric.
`_count` | Produces the row count for a given key. Values can be any valid JSON.
`_stats` | Produces a JSON structure containing sum, count, min, max and sum squared. Values must be numeric.

### Custom Reduces

> Example reduce function:

```javascript
// manually count unique keys
function (keys, values, rereduce) {
  if (rereduce){
    // Given an array of counts, sum them
    return values.reduce(function (a, b) {
      return a + b;
    }, 0);
  } else {
    // Given an array of keys, count them
    return values.length;
  }
}
```

Reduces are called with three parameters: `key`, `values` and `rereduce`. Keys will be a list of keys as emitted by the `map` function, or null; `values` will be a list of values for each element in `keys`; and `rereduce` will be `true` or `false`.

When `rereduce` is `false`, `keys` will be an array of arrays representing unique key and document ID pairs emitted by the index's `map` function, while `values` will be an array of values emitted by the index's `map` function. For example:

* keys: `[[key1, idA], [key1, idB], [key1, idC], [key2, idA], [key2, idD], [key3, idA]`
* values: `[key1value1, key1value2. key1value3, key2value1, key2value2, key3value1]`

When `rereduce` is `true`, `keys` will be `null`, while `values` will be an array of values returned by past iterations of the `reduce` function. For example:

* keys: `null`
* values: `[6, 3, 7]`

By feeding the results of `reduce` functions back into the `reduce` function, MapReduce is able to split up the analysis of huge datasets into discrete, parallelized tasks, which can be completed much faster.

### Queries

```shell
TODO
```

```python
TODO
```

Once you've got an index written, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$_ID/_view/$INDEX_NAME`.

**Query Parameters**

Argument | Description | Optional | Type | Default | Supported Values
---------|------------|----------|------|---------|-----------------
descending | Return the documents in descending by key order | yes | boolean | false | 
endkey | Stop returning records when the specified key is reached | yes | string or JSON array |  |  
endkey_docid | Stop returning records when the specified document ID is reached | yes | string |  |  
group | Group the results using the reduce function to a group or single row | yes | boolean | false | 
group_level | Only applicable if the view uses complex keys, i.e. keys that are JSON arrays. Groups reduce results for the specified number of array fields. | yes | numeric |  | 
include_docs | Include the full content of the documents in the response | yes | boolean | false | 
inclusive_end | included rows with the specified endkey | yes | boolean | true |  
key | Return only documents that match the specified key. Note that keys are JSON values and must be URL-encoded. | yes | string |  |  
limit | Limit the number of the returned documents to the specified number | yes | numeric |  | 
reduce | Use the reduce function | yes | boolean | true |  
skip | Skip this number of rows from the start | yes | numeric | 0 | 
stale | Allow the results from a stale view to be used. This makes the request return immediately. If this parameter is not given, a response will be returned after the view has been built. | yes | string | false | ok: Allow stale views, update_after: Allow stale views but update them after the request
startkey | Return records starting with the specified key | yes | string or JSON array |  |  
startkey_docid | Return records starting with the specified document ID | yes | string |  |  
