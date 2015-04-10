Query
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
-   **type (optional)**: Can be ``"json"`` or ``"text"``. Defaults to json. Geospatial indexes will be supported in the future.
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

> A simple selector

```json
{
  "name": "Paul"
}
```

Elementary selector syntax requires you to specify one or more fields, and the corresponding values required for those fields. This selector matches all documents whose `"name"` field has the value `"Paul"`.

You can create more complex selector expressions by combining operators.
However, you cannot use 'combination' or 'array logical' operators such as `$regex` as the *basis* of a query. Only the equality operators such as `$eq`, `$gt`, `$gte`, `$lt`, and `$lte` (but not `$ne`) can be used as the basis of a more complex query.
For more information about creating complex selector expressions, see [Creating selector expressions](#creating-selector-expressions).

###### selector with two fields

> A more complex selector

```json
{
  "name": "Paul",
  "location": "Boston"
}
```

This selector matches any document with a `name` field containing "Paul", that also has a `location` field with the value "Boston".

### Subfields

> Example of a field and subfield selector, using a standard JSON structure:

```json
{
  "location": {
    "city": "Omaha"
  }
}
```

A more complex selector enables you to specify the values for field of nested objects, or subfields.
For example, you might use the standard JSON structure for specifying a field and subfield.

<div></div>

###### h6

> Example of an equivalent dot-notation field and subfield selector:

```json
{
  "location.city": "Omaha"
}
```

An abbreviated equivalent uses a dot notation to combine the field and subfield names into a single name.

### Operators

> Example selector using an operator to match any document,
where the `age` field has a value greater than 20:

```json
{
  "age": {
    "$gt": 20
  }
}
```

Operators are identified by the use of a dollar sign (`$`) prefix in the name field.

There are two core types of operators in the selector syntax:

- Combination operators
- Condition operators

In general, combination operators are applied at the top level of selection.
They are used to combine conditions, or to create combinations of conditions, into one selector.

Every explicit operator has the form:

  `{"$operator": argument}`

A selector without an explicit operator is considered to have an implicit operator.
The exact implicit operator is determined by the structure of the selector expression.

### Implicit Operators

There are two implicit operators:

- Equality
- And

In a selector, any field containing a JSON value, but that has no operators in it, is considered to be an equality condition.
The implicit equality test applies also for fields and subfields.

Any JSON object that is not the argument to a condition operator is an implicit `$and` operator on each field.

###### h6

> Example of the implicit equality operator

```json
{
  "foo": "bar"
}
```

In this example, there must be a field `foo` in a matching document, *and* the field must have a value exactly equal to "bar".

<div></div>

###### h6

> Example of an explicit equality operator

```json
{
  "foo": {
    "$eq": "bar"
  }
}
```

You can also make the equality operator explicit.

<div></div>

###### h6

> Example of implicit operator applied to a subfield test

```json
{
  "foo": {
    "bar": "baz"
  }
}
```

In the example using subfields,
the required field `foo` in a matching document *must* also have a subfield `bar` *and* the subfield *must* have a value exactly equal to "baz".

<div></div>

> Example of an explicit equality operator

```json
{
  "foo": {
    "$eq": {
      "bar": "baz"
    }
  }
}
```

Again, you can make the equality operator explicit.

<div id="combined-expressions"></div>

###### h6

> Example of an implicit `$and` operator

```json
{
  "foo": "bar",
  "baz": true
}
```

In this example, the field `foo` must be present and contain the value `bar` _and_ the field `baz` must exist and have the value `true`.

<div></div>

###### h6

> Example of using explicit `$and` and `$eq` operators

```json
{
  "$and": [
    {
      "foo": {
        "$eq": "bar"
      }
    },
    {
      "baz": {
        "$eq": true
      }
    }
  ]
}
```

You can make both the `and` operator and the equality operator explicit.

### Combination Operators

Combination operators are used to combine selectors.
In addition to the common boolean operators found in most programming languages,
there are two combination operators (`$all` and `$elemMatch`) that help you work with JSON arrays.

A combination operator takes a single argument.
The argument is either another selector, or an array of selectors.

The list of combination operators:

Operator | Argument | Purpose
---------|----------|--------
`$and` | Array | Matches if all the selectors in the array match.
`$or` | Array | Matches if any of the selectors in the array match. All selectors must use the same index.
`$not` | Selector | Matches if the given selector does not match.
`$nor` | Array | Matches if none of the selectors in the array match.
`$all` | Array | Matches an array value if it contains all the elements of the argument array.
`$elemMatch` | Selector | Matches an array value if any of the elements in the array are matched by the argument to `$elemMatch`, then returns only the first match.

### Condition Operators

Condition operators are specific to a field, and are used to evaluate the value stored in that field. For instance, the basic `$eq` operator matches when the specified field contains a value that is equal to the supplied argument.

The basic equality and inequality operators common to most programming languages are supported. In addition, some 'meta' condition operators are available. Some condition operators accept any valid JSON content as the argument. Other condition operators require the argument to be in a specific JSON format.

Operator type | Operator | Argument | Purpose
--------------|----------|----------|--------
(In)equality | `$lt` | Any JSON | The field is less than the argument.
 | `$lte` | Any JSON | The field is less than or equal to the argument.
 | `$eq` | Any JSON | The field is equal to the argument.
 | `$ne` | Any JSON | The field is not equal to the argument.
 | `$gte` | Any JSON | The field is greater than or equal to the argument.
 | `$gt` | Any JSON | The field is greater than the argument.
Object | `$exists` | Boolean | Check whether the field exists or not, regardless of its value.
 | `$type` | String | Check the document field's type. Valid values are "null", "boolean", "number", "string", "array", and "object".
Array | `$in` | Array of JSON values | The document field must exist in the list provided.
 | `$nin` | Array of JSON values | The document field must not exist in the list provided.
 | `$size` | Integer | Special condition to match the length of an array field in a document. Non-array fields cannot match this condition.
Miscellaneous | `$mod` | [Divisor, Remainder] | Divisor and Remainder are both positive integers greater than 0. Matches documents where (field % Divisor == Remainder) is true. This is false for any non-integer field.
 | `$regex` | String | A regular expression pattern to match against the document field. Only matches when the field is a string value and matches the supplied regular expression.

<aside class="warning">Regular expressions do not work with indexes, so they should not be used to filter large data sets.</aside>

### Creating selector expressions

We have seen examples of combining selector expressions,
such as [using explicit `$and` and `$eq` operators](#combined-expressions).
In general,
whenever you have an operator that takes an argument,
that argument can itself be another operator with arguments of its own.
This enables us to build up more complex selector expressions.

However, not all operators can be used as the base or starting point of the selector expression.

<aside class="warning">You cannot use combination or array logical operators such as `$regex` as the *basis* of a query. Only equality operators such as `$eq`, `$gt`, `$gte`, `$lt`, `$lte` and `$ne` can be used as the basis of a query.</aside>

<div></div>

> Example of an invalid selector expression:

```json
{
  "selector": {
    "afieldname": {
      "$regex": "^A"
    }
  }
}
```

> Example response to an invalid selector expression:

```json
{
  error: "no_usable_index"
  reason: "There is no operator in this selector can used with an index."
}
```

For example,
if you try to perform a query that attempts to match all documents that have a field called `afieldname` containing a value that begins with the letter `A`,
you get an `error: "no_usable_index"` error message.

<div></div>

> Example use of an equality operator to enable a selector expression:

```json
{
  "selector": {
    "_id": {
      "$gt": null
    },
    "afieldname": {
      "$regex": "^A"
    }
  }
}
```

A solution is to use an equality operator as the basis of the query.
You can add a 'null' or always true expression as the basis of the query.
For example,
you could first test that the document has an `_id` value:

  `"_id": { "$gt": null }`

This expression is always true,
enabling the remainder of the selector expression to be applied.

<aside class="warning">Using `{"_id": { "$gt":null } }` induces a full-table scan, and is not efficient for large databases.</aside>

Most selector expressions work exactly as you would expect for the given operator.
The matching algorithms used by the `$regex` operator are currently based on the Perl Compatible Regular Expression (PCRE) library.
However, not all of the PCRE library is implemented,
and some parts of the `$regex` operator go beyond what PCRE offers.
For more information about what is implemented,
see the <a href="http://erlang.org/doc/man/re.html" target="_blank">Erlang Regular Expression</a> information.

### Sort Syntax

> Example of simple sort syntax:

```json
[{"fieldName1": "desc"}, {"fieldName2": "desc" }]
```

The sort syntax uses a basic array of field name and direction pairs.
The first field name and direction pair is the topmost level of sort.
The second pair, if provided is the next level of sort.

The `field` can be any field, using dotted notation if desired for sub-document fields.
The direction value is `"asc"` for ascending, and `"desc"` for descending.

> A simple query, using sorting:

```json
{
    "selector": {"Actor_name": "Robert De Niro"},
    "sort": [{"Actor_name": "asc"}, {"Movie_runtime": "asc"}]
}
```

A typical requirement is to search for some content using a selector,
then to sort the results according to the specified field, in the required direction.

To use sorting, ensure that:

- At least one of the sort fields is included in the selector.
- There is an index already defined, with all the sort fields in the same order.
- Each object in the sort array has a single key.

<aside class="warning">If an object in the sort array does not have a single key, the resulting sort order is implementation specific and might change.</aside>

<aside>Currently, Cloudant Query does not support multiple fields with different sort orders, so the directions must be either all ascending or all descending.</aside>

If the direction is ascending, you can use a string instead of an object to specify the sort fields.

### Filtering fields

> Example of selective retrieval of fields from matching documents:

```json
{
    "selector": { "Actor_name": "Robert De Niro" },
    "fields": ["Actor_name", "Movie_year", "_id", "_rev"]
}
```

It is possible to specify exactly which fields are returned for a document when selecting from a database.
The two advantages are:

- Your results are limited to only those parts of the document that are required for your application.
- A reduction in the size of the response.

The fields returned are specified as an array.

<aside>Only the specified filter fields are included, in the response.
There is no automatic inclusion of the `_id` or other metadata fields when a field list is included.</aside>


