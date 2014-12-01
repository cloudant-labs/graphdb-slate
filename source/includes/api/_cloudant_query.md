Cloudant Query
--------------

The Cloudant Query endpoints can be used to create, list, update, and delete indexes in a database and to query data using these indexes.

A list of the available methods and endpoints is provided below:

Method | Path | Description
-------|------|------------
POST | /db/_index | Create a new index
GET | /db/_index | List all indexes
DELETE | /db/_index | Delete an index
POST| /db/_find | Find documents using an index

### Creating a new index

> Example of creating a new index for the field called `foo`:

```shell
POST /db/_index HTTP/1.1
Content-Type: application/json
```

```json
{
    "index": {
        "fields": ["foo"]
    },
    "name" : "foo-index",
    "type" : "json"
}
```

> The returned JSON confirms the index has been created:

```json
{
    "result": "created"
}
```

-   **Method**: `POST`
-   **URL Path**: `/db/_index`
-   **Request Body**: JSON object describing the index to be created
-   **Response Body**: JSON object indicating successful creation of the index or describing an error
-   **Roles permitted**: \_writer

Creates a new index in the specified database using the information supplied in the request body.

#### Request Body

-   **index**:
    -   **fields**: A JSON array of field names following the [sort syntax](#sort-syntax). Nested fields are also allowed, e.g. `"person.name"`.
-   **ddoc (optional)**: Name of the design document in which the index will be created. By default, each index will be created in its own design document. Indexes can be grouped into design documents for efficiency. However, a change to one index in a design document will invalidate all other indexes in the same document.
-   **type (optional)**: Defaults to json, which is currently the only supported type. Full text indexes and geospatial indexes will be provided in the future.
-   **name (optional)**: Name of the index. If no name is provided, one will be generated automatically.

#### Return Codes

Code | Description
-----|------------
200 | Index has been created successfully or already existed
400 | Bad request: the request body does not have the specified format

### List all indexes

-   **Method**: `GET`
-   **URL Path**: `/db/_index`
-   **Response Body**: JSON object describing the indexes
-   **Roles permitted**: \_reader

When you make a `GET` request to `/db/_index`, you get a list of all indexes in the database. In addition to the information available through this API, indexes are also stored in design documents &lt;index-functions&gt;. Design documents are regular documents that have an ID starting with `_design/`. Design documents can be retrieved and modified in the same way as any other document, although this is not necessary when using Cloudant Query.

#### Response body

> An example of a response body with two indexes

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

-   **indexes**: Array of indexes
    -   **ddoc**: ID of the design document the index belongs to. This ID can be used to retrieve the design document containing the index,
    by making a `GET` request to `/db/ddoc`, where `ddoc` is the value of this field.
    -   **name**: Name of the index.
    -   **type**: Type of the index. Currently "json" is the only supported type.
    -   **def**: Definition of the index, containing the indexed fields and the sort order: ascending or descending.

### Deleting an index

-   **Method**: `DELETE`
-   **URL Path**: `/$db/_index/$designdoc/$type/$name` where $db is the name of the database, $designdoc is the ID of the design document, $type is the type of the index (for example "json"),
and $name is the name of the index.
-   **Response Body**: JSON object indicating successful deletion of the index, or describing any error encountered.
-   **Request Body**: None
-   **Roles permitted**: \_writer

### Finding documents using an index

-   **Method**: `POST`
-   **URL Path**: `/db/_find`
-   **Response Body**: JSON object describing the query results
-   **Roles permitted**: \_reader

#### Request body

> Example request body for finding documents using an index:

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

-   **selector**: JSON object describing criteria used to select documents. More information provided in the section on [selectors](#selector-syntax).
-   **limit (optional, default: 25)**: Maximum number of results returned.
-   **skip (optional, default: 0)**: Skip the first 'n' results, where 'n' is the value specified.
-   **sort (optional, default: [])**: JSON array following [sort syntax](#sort-syntax)
-   **fields (optional, default: null)**: JSON array following the field syntax, described below. This parameter lets you specify which fields of an object should be returned. If it is omitted, the entire object is returned.
-   **r (optional, default: 1)**: Read quorum needed for the result. This defaults to 1, in which case the document found in the index is returned. If set to a higher value, each document is read from at least that many replicas before it is returned in the results. This is likely to take more time than using only the document stored locally with the index.

#### Response body

> Example response when finding documents using an index:

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

-   **docs**: Array of documents matching the search. In each matching document, the fields specified in the `fields` part of the request body are listed, along with their values.

### Selector Syntax

The Cloudant Query language is expressed as a JSON object describing documents of interest. Within this structure, you can apply conditional logic using specially named fields.

<aside class="notice">While the Cloudant Query language has some similarities with MongoDB query documents, these arise from a similarity of purpose and do not necessarily extend to commonality of function or result.</aside>

#### Selector basics

> A simple selector to match any documents with the `name` "Paul":

```json
{"name": "Paul"}
```

> A more complex selector that matches any document with `name` "Paul", and that also has a `location` field with the value "Boston":

```json
{"name": "Paul", "location": "Boston"}
```

Elementary selector syntax requires you to specify one or more fields, and the corresponding values required for those fields.

### Subfields

> Example of a field and subfield selector, using a standard JSON structure:

```json
{"location": {"city": "Omaha"}}
```

> Example of an equivalent dot-notation field and subfield selector:

```json
{"location.city": "Omaha"}
```

A more complex selector enables you to specify the values for fields and subfields.
For example, you might use the standard JSON structure for specifying a field and subfield.
However, an abbreviated equivalent uses a dot notation to combine the field and subfield names into a single name.

### Operators

> Example selector to match any document where the `age` field has a value greater than 20:

```json
{"age": {"$gt": 20}}
```

Operators are identified by the use of a dollar sign ($) prefix in the name field.

There are two core types of operators in the selector syntax:

- Combination operators
- Condition operators

In general, combination operators are applied at the top level of selection.
They are used to combine conditions, or to create combinations of conditions, into one selector.

Every explicit operator has the form `{"$operator": argument}`.
A selector without an explicit operator is considered to have an implicit operator.
The exact implicit operator is determined by the context of the selector expression.

### Implicit Operators

> Example of implicit operator, where the field `foo` in a matching document must have a value exactly equal to "bar":

```json
{"foo": "bar"}
```

> Example of an explicit operator providing the equivalent test of matching for equality:

```json
{"foo": {"$eq": "bar"}}
```

> Example of implicit operator applied to a subfield test, where the field `foo` in a matching document must a subfield `bar` with a value exactly equal to "baz":

```json
{"foo": {"bar": "baz"}}
```

> Example of an explicit operator providing the equivalent test of matching for equality in subfields:

```json
{"foo": {"$eq": {"bar": "baz"}}}
```

> Example of an implicit `$and` operator, specifying a match for foo=bar _and_ baz=true:

```json
{"foo": "bar", "baz": true}
```

> Example of explicit `$and` and `$eq` operators, specifying a match for foo=bar _and_ baz=true:

```json
{"$and": [{"foo": {"$eq": "bar"}}, {"baz": {"$eq": true}}]}
```

There are two implicit operators:

- Equality
- And

In a selector, any field containing a JSON value but that has no operators in it, is considered to be an equality condition.
The implicit equality test applies also for fields and subfields.

Any JSON object that is not the argument to a condition operator is an implicit `$and` operator on each field.

<hr/>

###### dummy 

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

```json
[{"fieldName1": "desc"}, {"fieldName2": "desc" }]
```

The sort syntax is a basic array of field name and direction pairs. It looks like this:

###### dummy

```json
{
    "selector": {"Actor_name": "Robert De Niro"},
    "sort": [{"Actor_name": "asc"}, {"Movie_runtime": "asc"}]
}
```

Here is a query using sorting:

###### dummy 

```json
["fieldName1", "fieldName2", "and_so_on"]
```

Where `fieldName` can be any field (dotted notation is available for sub-document fields) and the value can be `"asc"` or `"desc"`. One of the fields have to be used in the selector as well and there has to be an index defined with all sort fields in the same order. Each object in the array should have a single key. If it does not, the resulting sort order is implementation specific and might change. Currently, Cloudant Query does not support multiple fields with different sort orders, so the directions have to be either all ascending or all descending.

If the direction is ascending, you can use a string instead of an object to specify the sort fields.

### Filtering fields

```json
{
    "selector": { "Actor_name": "Robert De Niro" },
    "fields": ["Actor_name", "Movie_year", "_id", "_rev"]
}
```

When retrieving documents from the database you can specify that only a subset of the fields are returned. This allows you to limit your results strictly to the parts of the document that are interesting for your application and reduces the size of the response. The fields returned are specified as an array. Unlike MongoDB, only the fields specified are included, there is no automatic inclusion of the "\_id" or other metadata fields when a field list is included.


