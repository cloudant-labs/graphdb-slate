Cloudant Query
--------------

The Cloudant Query endpoints can be used to create, list, update, and delete indexes in a database and to query data using these indexes.

A list of the available methods and endpoints is provided below:

<table>
<colgroup>
<col width="9%" />
<col width="22%" />
<col width="68%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Method</th>
<th align="left">Path</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">POST</td>
<td align="left">/db/_index</td>
<td align="left">Create a new index</td>
</tr>
<tr class="even">
<td align="left">GET</td>
<td align="left">/db/_index</td>
<td align="left">List all indexes</td>
</tr>
<tr class="odd">
<td align="left">DELETE</td>
<td align="left">/db/_index</td>
<td align="left">Delete an index</td>
</tr>
<tr class="even">
<td align="left">POST</td>
<td align="left">/db/_find</td>
<td align="left">Find documents using an index</td>
</tr>
</tbody>
</table>

### Creating a new index

-   **Method**: `POST`
-   **URL Path**: `/db/_index`
-   **Request Body**: JSON object describing the index to be created
-   **Response Body**: JSON object indicating successful creation of the index or describing an error
-   **Roles permitted**: \_writer

Creates a new index in the specified database using the information supplied in the request body.

#### Request Body

-   **index**:
    -   **fields**: A JSON array of field names following the sort syntax \<cloudant-query-sort-syntax\>. Nested fields are also allowed, e.g. `"person.name"`.
-   **ddoc (optional)**: Name of the design document in which the index will be created. By default, each index will be created in its own design document. Indexes can be grouped into design documents for efficiency. However, a change to one index in a design document will invalidate all other indexes in the same document.
-   **type (optional)**: Defaults to json, which is currently the only supported type. Full text indexes and geospatial indexes will be provided in the future.
-   **name (optional)**: Name of the index. If no name is provided, one will be generated automatically.

#### Return Codes

<table>
<colgroup>
<col width="8%" />
<col width="91%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Code</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">200</td>
<td align="left">Index has been created successfully or already existed</td>
</tr>
<tr class="even">
<td align="left">400</td>
<td align="left">Bad request, i.e. the request body does not have the specified format</td>
</tr>
</tbody>
</table>

For example, you can create a new index for the `foo` field with the following request:

```http
POST /db/_index HTTP/1.1
Content-Type: application/json

{
    "index": {
        "fields": ["foo"]
    },
    "name" : "foo-index",
    "type" : "json"
}
```

The returned JSON confirms the index has been created:

```json
{
    "result": "created"
}
```

### List all indexes

-   **Method**: `GET`
-   **URL Path**: `/db/_index`
-   **Response Body**: JSON object describing the indexes
-   **Roles permitted**: \_reader

With a `GET` request to `/db/_index` you get a list of all indexes in the database. In addition to the information available through this API, indexes are also stored in design documents \<index-functions\>. Design documents are regular documents whose ID starts with `_design/` and they can be retrieved and modified like any other document, although this isn't necessary when using Cloudant Query.

#### Response body

-   **indexes**: Array of indeces
    -   **ddoc**: ID of the design document the index belongs to. This ID can be used to retrieve the design document containing the index with a `GET` request to `/db/ddoc`, where `ddoc` is the value of this field.
    -   **name**: Name of the index.
    -   **type**: Type of the index. Currently "json" is the only supported type.
    -   **def**: Definition of the index, containing the indexed fields and the sort order, i.e. ascending or descending.

An example of a response body with two indexes:

```json
{
    "indexes": [
        {
            "ddoc": "_design/2ec1805041b2c3dcdef1d07a8ea1dc51ba3decfa",
            "name": "foo-bar-index",
            "type": "json",
            "def": {
                "fields": [
                    {"foo":"asc"},
                    {"bar":"asc"}
                ]
            }
        },
        {
            "ddoc": "_design/1f003ce73056238720c2e8f7da545390a8ea1dc5",
            "name": "baz-index",
            "type": "json",
            "def": {
                "fields": [
                    {"baz":"desc"}
                 ]
             }
         }
    ]
}
```

### Deleting an index

-   **Method**: `DELETE`
-   **URL Path**: `/$db/_index/$designdoc/$type/$name` where $db is the name of the database, $designdoc is the ID of the design document, $type is the type of the index (e.g. json), and $name is the name of the index.
-   **Response Body**: JSON object indicating successful deletion of the index or describing an error
-   **Request Body**: None
-   **Roles permitted**: \_writer

### Finding documents using an index

-   **Method**: `POST`
-   **URL Path**: `/db/_find`
-   **Response Body**: JSON object describing the query results
-   **Roles permitted**: \_reader

#### Request body

-   **selector**: JSON object describing criteria used to select documents. See the section on selectors \<cloudant-query-selectors\> below.
-   **limit (optional, default: 25)**: maximum number of results returned
-   **skip (optional, default: 0)**: skip the first n results, where n is the value specified
-   **sort (optional, default: [])**: JSON array following sort syntax \<cloudant-query-sort-syntax\>
-   **fields (optional, default: null)**: JSON array following the field syntax, described below. This parameter lets you specify which fields of an object should be returned. If it is omitted, the entire object is returned.
-   **r (optional, default: 1)**: Read quorum needed for the result. This defaults to 1, in which case the document found in the index is returned. If set to a higher value, each document is read from at least that many replicas before it is returned in the results. This is obviously less performant than using the document local to the index.

```json
{
    "selector": {
        "bar": {"$gt": 1000000}
    },
    "fields": ["_id", "_rev", "foo", "bar"],
    "sort": [{"bar": "asc"}],
    "limit": 10,
    "skip": 0
}
```

#### Response body

-   **docs**: Array of documents matching the search

```json
{
    "docs":[
        {
            "_id": "2",
            "_rev": "1-9f0e70c7592b2e88c055c51afc2ec6fd",
            "foo": "test",
            "bar": 2600000
        },
        {
            "_id": "1",
            "_rev": "1-026418c17a353a9b73a6ccac19c142a4",
            "foo":"another test",
            "bar":9800000
        }
    ]
}
```

### Selector Syntax

The Cloudant Query language is expressed as a JSON object describing documents of interest. Within this structure it is also possible to express conditional logic using specially named fields. This is inspired by and intended to maintain a fairly close parity to MongoDB query documents.

As an example, a simple selector looks like this:

```json
{"name": "Paul"}
```

This selector matches any documents with the `name` "Paul". Extending this example using other fields:

```json
{"name": "Paul", "location": "Boston"}
```

This selector matches a document with `name` Paul, that also has a "location" field with the value of "Boston".

There are two special syntax elements for the object fields in a selector. The first is that the dot character denotes subfields in a document. For instance, here are two equivalent examples:

```json
{"location": {"city": "Omaha"}}
```

```json
{"location.city": "Omaha"}
```

The second important syntax element is the use of a dollar sign ($) prefix to denote operators. For example:

```json
{"age": {"$gt": 20}}
```

In this example, any document where the age field has a value greater than 20 will be machted.

There are two core types of operators in the selector syntax: combination operators and condition operators. In general, combination operators are at the top level and combine conditions or combinations of confitions into one selector. We'll describe each operator below.

### Implicit Operators

For the most part every operator must be of the form {"$operator": argument}. Though there are two implicit operators for selectors.

Any field that contains a JSON value that has no operators in it is an equality condition. For instance, these are equivalent:

```json
{"foo": "bar"}
```

```json
{"foo": {"$eq": "bar"}}
```

And to be clear, these are also equivalent:

```json
{"foo": {"bar": "baz"}}
```

```json
{"foo": {"$eq": {"bar": "baz"}}}
```

Any JSON object that is not the argument to a condition operator is an implicit $and operator on each field. For instance, these two examples are identical:

```json
{"foo": "bar", "baz": true}
```

```json
{"$and": [{"foo": {"$eq": "bar"}}, {"baz": {"$eq": true}}]}
```

### Combination Operators

Combination operators are responsible for combining selectors. In this group of operators you find the familiar boolean operators as well as two for working with JSON arrays.

Each of the combining operators take a single argument that is either a selector or an array of selectors.

The list of combining characters:

-   `$and`: array argument, matches if all the selectors in the array match
-   `$or`: array argument, matches if any of the selectors in the array match. All selectors need to use the same index.
-   `$not`: single argument, matches if the given selector does not match
-   `$nor`: array argument, matches if none of the selectors in the array match
-   `$all`: array argument, matches an array value if it contains all the elements of the argument array
-   `$elemMatch`: single argument, matches an array value if any of the elements are matched by the argument to elemMatch and returns only the first such match

### Condition Operators

Condition operators are specified on a per field basis and apply to the value indexed for that field. For instance, the basic "$eq" operator matches when the indexed field is equal to its argument. There is currently support for the basic equality and inequality operators as well as a number of meta operators. Some of these operators will accept any JSON argument while some require a specific JSON formatted argument. Each is noted below.

The list of conditional arguments:

(In)equality operators

-   `$lt`: any JSON
-   `$lte`: any JSON
-   `$eq`: any JSON
-   `$ne`: any JSON
-   `$gte`: any JSON
-   `$gt`: any JSON

Object related operators

-   `$exists`: boolean, check whether the field exists or not regardless of its value
-   `$type`: string, check the document field's type. Valid values are "null", "boolean", "number", "string", "array", and "object".

Array related operators

-   `$in`: array of JSON values, the document field must exist in the list provided
-   `$nin`: array of JSON values, the document field must not exist in the list provided
-   `$size`: integer, special condition to match the length of an array field in a document. Non-array fields cannot match this condition.

Miscellaneous operators

-   `$mod`: [Divisor, Remainder], where Divisor and Remainder are both positive integers (ie, greater than 0). Matches documents where (field % Divisor == Remainder) is true. This is false for any non-integer field
-   `$regex`: string, a regular expression pattern to match against the document field. Only matches when the field is a string value and matches the supplied regular expression. The matching algorithms are currently based on the PCRE library, but not all of the PCRE library is interfaced and some parts of the library go beyond what PCRE offers. See <http://erlang.org/doc/man/re.html>. Regular expressions also don't benefit from indexes, so they should not be used to filter large data sets.

### Sort Syntax

###### dummy

The sort syntax is a basic array of field name and direction pairs. It looks like this:

```json
[{"fieldName1": "desc"}, {"fieldName2": "desc" }]
```

###### dummy

Here is a query using sorting:

```json
{
    "selector": {"Actor_name": "Robert De Niro"},
    "sort": [{"Actor_name": "asc"}, {"Movie_runtime": "asc"}]
}
```

Where `fieldName` can be any field (dotted notation is available for sub-document fields) and `dir` can be `"asc"` or `"desc"`. One of the fields have to be used in the selector as well and there has to be an index defined with all sort fields in the same order. Each object in the array should have a single key. If it does not, the resulting sort order is implementation specific and might change. Currently, Cloudant Query does not support multiple fields with different sort orders, so the directions have to be either all ascending or all descending.

If the direction is ascending, you can use a string instead of an object to specify the sort fields.

```json
["fieldName1", "fieldName2", "and_so_on"]
```

### Filtering fields

When retrieving documents from the database you can specify that only a subset of the fields are returned. This allows you to limit your results strictly to the parts of the document that are interesting for your application and reduces the size of the response. The fields returned are specified as an array. Unlike MongoDB, only the fields specified are included, there is no automatic inclusion of the "\_id" or other metadata fields when a field list is included.

A trivial example:

```json
{
    "selector": { "Actor_name": "Robert De Niro" },
    "fields": ["Actor_name", "Movie_year", "_id", "_rev"]
}
```
