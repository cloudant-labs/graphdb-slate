## Query Text Indexes

Cloudant Query has support for [creating indexes](api.html#creating-a-new-index)
using [Apache Lucene](http://lucene.apache.org/).
This capability provides several benefits, including:

-	Full Text Indexing (FTI)
-	Arbitrary queries

This guide describes the featutes, and explains how to use them.

### Overview

To get the benefits from Full Text Indexing (FTI),
you should already be familiar with the basics of using Cloudant.

There are four basic steps to work with FTI:

<div id="step01"></div>
#### 1. Create a database, or use an existing database

> Example command to create a Cloudant database:

```http
PUT /dbname HTTP/1.1
Host: user.cloudant.com
```

```shell
curl -X PUT https://user.cloudant.com/dbname
```

<div id="step02"></div>
#### 2. Create a text index

> Example command to create a text index within the database:

```http
POST /dbname/_index HTTP/1.1
Content-Type: application/json
Host: user.cloudant.com

{
  "index": {},
  "type": "text"
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_index \
  -d '{"index":{}, "type": "text"}'
```

<div id="step03"></div>
#### 3. Add a document

> Example command to create a simple document:

```http
POST /dbname HTTP/1.1
Content-Type: application/json
Host: user.cloudant.com

{
  "character":"Frodo Baggins",
  "type": "Hobbit",
  "height":4
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname \
  -d '{"character":"Frodo Baggins", "type": "Hobbit", "height":4}'
```

<div id="step04"></div>
#### 4. Query for the document

> Example command to query for a document that matches text precisely:

```http
POST /dbname/_find HTTP/1.1
HOST: user.cloudant.com
Content-Type: application/json

{
  "selector": {
    "$text": "Frodo"
  }
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_find \
  -d '{"selector":{"$text": "Frodo"}}'
```

> Example command to query for a document that matches a condition:

```shell
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_find \
  -d '{"selector":{"$or": [{"type":"Orc"}, {"height": {"$lt":4.5}}]}'
```

### Working with real data

> Obtaining a copy of the Cloudant Query movie database:

```http
POST /_replicate HTTP/1.1
Host: user.cloudant.com
Content-Type: application/json

{
  "source": "https://examples.cloudant.com/movies-demo",
  "target": "https://<user:password>@<user>.cloudant.com/my-movies-demo",
  "create_target": true,
  "use_checkpoints": false
}
```

```shell
curl 'https://<user:password>@<user>.cloudant.com/_replicate' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "source": "https://examples.cloudant.com/movies-demo",
    "target": "https://<user:password>@<user>.cloudant.com/my-movies-demo",
    "create_target": true,
    "use_checkpoints": false
}'
```

> Results after successful replication of the Cloudant Query movie database:

```json
{
  "ok": true,
  "use_checkpoints": false
}
```

To describe FTI, it is helpful to have a large collection of data to work with.
A suitable collection is available in the example Cloudant Query movie database: `movies-demo`.
You can obtain a copy of this database in your database, with the name `my-movies-demo`,
by running the command shown.

The sample database contains approximately 3,000 documents, and is just under 1 MB in size.

<div></div>

> Creating a _text_ index for your sample database:

```http
POST /my-movies-demo/_index HTTP/1.1
Host: user.cloudant.com
Content-Type: application/json

{
  "index": {},
  "type": "text"
}
```

```shell
curl 'https://<user:password>@<user>.cloudant.com/my-movies-demo/_index' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"index": {}, "type": "text"}'
```

> Response after creating a text index:

```json
{
  "result": "created"
}
```

Before we can search the content, we must index it. We do this by creating a text index for the documents.
<aside class="notice">We do not index any specific field, we do not need to provide and index name, and the index type is `text`.</aside>

<div></div>

> Searching for a specific document within the database:

```http
POST /my-movies-demo/_find HTTP/1.1
Host: user.cloudant.com
Content-Type: application/json

{
  "selector": {
    "Person_name":"Zoe Saldana"
  }
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
        https://<user:password>@<user>.cloudant.com/my-movies-demo/_find \
        -d '{"selector": {"Person_name":"Zoe Saldana"}}'
```

> Example result from the search:

```json
{
  "docs": [
    {
      "_id": "d9e6a7ae2363d6cfe81af75a3941110b",
      "_rev": "1-556aec0e89fa13769fbf59d651411528",
      "Movie_runtime": 162,
      "Movie_rating": "PG-13",
      "Person_name": "Zoe Saldana",
      "Movie_genre": "AVYS",
      "Movie_name": "Avatar",
      "Movie_earnings_rank": "1",
      "Person_pob": "New Jersey, USA",
      "Movie_year": 2009,
      "Person_dob": "1978-06-19"
    }
  ],
  "bookmark": "g2wA ... Omo"
}
```

The most obvious difference in the results you get when using FTI is the inclusion of a large `bookmark` field. The reason is that text indexes are different to view-based indexes. To work with the results obtained from an FTI query, you must supply the `bookmark` value as part of the request body. Without the `bookmark`, the FTI query system cannot know exactly what search you performed to obtain the original result set.

<aside class="warning">The actual `bookmark` value is very long, so the examples here are truncated for reasons of clarity.</aside>

<div></div>

> Example of a slightly more complex search:

```http
POST /my-movies-demo/_find HTTP/1.1
Host: user.cloudant.com
Content-Type: application/json

{
  "selector": {
    "Person_name":"Robert De Niro",
    "Movie_year": 1978
  }
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
        https://<user:password>@<user>.cloudant.com/my-movies-demo/_find \
        -d '{"selector": {"Person_name":"Robert De Niro", "Movie_year": 1978}}'
```

> Example result from the search:

```json
{
  "docs": [
    {
      "_id": "d9e6a7ae2363d6cfe81af75a392eb9f2",
      "_rev": "1-9faa75d7ea524448b1456a6c69a4391a",
      "Movie_runtime": 183,
      "Movie_rating": "R",
      "Person_name": "Robert De Niro",
      "Movie_genre": "DW",
      "Movie_name": "Deer Hunter, The",
      "Person_pob": "New York, New York, USA",
      "Movie_year": 1978,
      "Person_dob": "1943-08-17"
    }
  ],
  "bookmark": "g2w ... c2o"
}
```

> Example of searching within a range:

```http
POST /my-movies-demo/_find HTTP/1.1
Host: user.cloudant.com
Content-Type: application/json

{
  "selector": {
    "Person_name":"Robert De Niro",
    "Movie_year": {
      "$in": [1974, 2009]
    }
  }
}
```

```shell
curl -X POST -H "Content-Type: application/json" \
        https://<user:password>@<user>.cloudant.com/my-movies-demo/_find \
        -d '{"selector": {"Person_name":"Robert De Niro", "Movie_year": { "$in": [1974, 2009]}}}'
```

> Example result from the search:

```json
{
  "docs": [
    {
      "_id": "d9e6a7ae2363d6cfe81af75a392eb9f2",
      "_rev": "1-9faa75d7ea524448b1456a6c69a4391a",
      "Movie_runtime": 183,
      "Movie_rating": "R",
      "Person_name": "Robert De Niro",
      "Movie_genre": "DW",
      "Movie_name": "Deer Hunter, The",
      "Person_pob": "New York, New York, USA",
      "Movie_year": 1978,
      "Person_dob": "1943-08-17"
    }
  ],
  "bookmark": "g2w ... c2o"
}
```

#### The $text operator

The `$text` operator has full access to the Lucene query syntax. The resulting query is `AND`'ed with the rest of the
selector. For more information on the available Lucene syntax, have a look at the (Cloudant Search documentation)[http://docs.cloudant.com/api.html#search].

### Other Query Parameters

> Example using all available query parameters

```json
{
  "selector": {
    "query": "here"
  },
  "fields": [
    "_id",
    "_rev",
    "foo",
    "bar"
  ],
  "sort": [
    {
      "bar:number": "asc"
    },
    {
      "foo:string": "asc"
    }
  ],
  "bookmark": "opaque string",
  "limit": 10,
  "skip": 0
}
```

The format of the `selector` field is described in the (Cloudant Query documentation)[http://docs.cloudant.com/api.html#cloudant-query] with the
exception of the new `$text` operator. This operator applies to all strings found in the
document. In the selector, it must be placed at the very top level. It is invalid to place this
operator in the context of a field name.

The `fields` array is a list of fields that should be returned for each document. The provided
field names can use dotted notation to access subfields as well. Array elements can be accessed
using integers indexes.

The `sort` field contains a list of field name and direction pairs. For field names in text search sorts it is
sometimes necessary that a field type is specified as shown in the example. If possible we'll
attempt to discover the field type based on the selector but in ambiguous cases we require it to
be provided explicitly. You can discover the reason for this type specification in the
implementation notes below.

<aside class="warning">
The sorting order is undefined when fields contain different data types. This is an important difference between text and view indexes. Sorting behavior for fields with different data types might change in future versions.
</aside>

The `bookmark` field is used for paging through result sets. Every query will return an opaque
string under the `bookmark` key that can then be passed back in a query to get the next page of
results. If any part of the query other than `bookmark` changes between requests, the results are
undefined.

The `limit` and `skip` values are exactly as you would expect. While `skip` exists, it is not
intended to be used for paging as the implementation is much less efficient than using the
`bookmark` feature.

### Index Creation Parameters

> Example index creation request

```json
{
  "type": "text",
  "name": "my-index",
  "ddoc": "my-index-design-doc",
  "w": "2",
  "index": {
    "default_field": {
      "enabled": true,
      "analyzer": "german"
    }
    "selector": {}
    "fields": [
      {"name": "married", "type": "boolean"},
      {"name": "lastname", "type": "string"},
      {"name": "year-of-birth", "type": "number"}
    ]
  }
}
```

While it is generally recommended that you create a single text index with the default values there
are a few useful index attributes that can be modified.

For text indexes, `type` should obviously be set to `text`.

The `name` and `ddoc` attributes are for grouping indexes into design documents and allowing them to be referred to by a
custom string value. If no values are supplied for these fields, they are automatically
populated with a hash value. If you create multiple text indexes in a database, you will need to
know at least the `ddoc` value as well as the `name` value if you create multiple text indexes with
the same `ddoc` value. Creating multiple indexes with the same `ddoc` value places them into the
same design document. Generally, you should put each text index into its own design document.

The `w` value affects the consistency of the index creation operation. In general use, you
shouldn't have to worry about this, but if you create test or example scripts that attempt to use
the index immediately after use, it can be useful to set this to `3`, so that a complete quorum is
used for the creation. It does not affect anything other than index creation.

The `index` field contains settings specific to text indexes.

The `defualt_field` value affects how the index for handling the `$text` operator is created. In
almost all cases this should be left enabled by either not including the enabled field or setting
it to true.

The `analyzer` key in the `default_field` can be used to choose how to analyze text included
in the index. You can reference the Cloudant Search documentation)[http://docs.cloudant.com/api.html#analyzers] for alternative analyzers.
This would most often be changed when documents are indexed in languages other than English or when you have other special requirements for the analyser, e.g. matching email addresses.

The `selector` field can be used to limit the index to a specific set of documents that match
a query. It uses the same syntax used for selectors in queries. This can be used if your application
requires different documents to be indexed in different ways or if some documents should not be indexed at all.
If you only need to separate documents by type, it is easier to use one index and add the type to the search query.

The `fields` array can contain a list of fields that should be indexed for each document. If you
know that an index will only ever need to query on specific fields, then this can be used to limit
the size of the index. Each field must also specify a type that will be indexed. The acceptable
types are `"boolean"` , `"string"`, and `"number"`. An explanation of what these types mean
can be found in the implementation notes.


### Implementation Notes

The basic premise for text indexes is that a document is "exploded" into a list of key/value pairs
that are indexed by Lucene. This allows us to make use of Lucene's query operation by
translating from the Mongo-like selector syntax to Lucene's search syntax.

#### Document "Explosion"

> Example document to be indexed

```json
{
  "name": "Falcon 9",
  "manufacturer": "SpaceX",
  "launches": {
    "total": 13,
    "successful": 13
  },
  "height": {
    "magnitude": 68.4,
    "units": "m"
  },
  "diameter": {
    "magnitude": 3.7,
    "units": "m"
  },
  "mass": {
    "magnitude": 505846,
    "units": "kg"
  },
  "payload": {
    "to_leo": {
      "magnitude": 13150,
      "units": "kg"
    },
    "to_gto": {
      "magnitude": 4850,
      "units": "kg"
    }
  },
  "stages": [
    {
      "name": "first",
      "purpose": "thrust",
      "number": 1,
      "inhabitable": false,
      "engines": 9,
      "burn_time": 180,
      "thrust": [
        {
          "environment": "sea level",
          "magnitude": 5885,
          "units": "kN"
        },
        {
          "environment": "vacuum",
          "magnitude": 6672,
          "units": "kN"
        }
      ]
    },
    {
      "name": "second",
      "purpose": "thrust",
      "number": 2,
      "inhabitable": false,
      "engines": 1,
      "burn_time": 375,
      "thrust": [
        {
          "environment": "vacuum",
          "magnitude": 801,
          "units": "kN"
        }
      ]
    },
    {
      "name": "interstage",
      "purpose": "separation",
      "number": 3,
      "inhabitable": false,
      "engines": null,
      "notes": "pneumatic release"
    },
    {
      "name": "payload",
      "purpose": "payload",
      "number": 4,
      "inhabitable": true
    }
  ]
}
```

> List of key/value pairs produced

```
name:string	Falcon                                         9
manufacturer:string                                        "SpaceX"
launches.total:number                                      13
launches.successful:number                                 13
height.magnitude:number                                    68.4
height.units:string                                        "m"
diameter.magnitude:number                                  3.7
diameter.units:string                                      "m"
mass.magnitude:number                                      505846
mass.units:string                                          "kg"
payload.to_leo.magnitude:number                            13150
payload.to_leo.units:string                                "kg"
payload.to_gto.magnitdue:number                            4850
payload.to_gto.units:string                                "kg"
stages.[].name:string                                      "first"
stages.[].purpose:string                                   "thrust"
stages.[].number:number                                    1
stages.[].inhabitable:boolean                              FALSE
stages.[].engines:number                                   9
stages.[].burn_time:number                                 180
stages.[].thrust.[].environment:string                     "sea level"
stages.[].thrust.[].magnitude:number                       5885
stages.[].thrust.[].units:string                           "kN"
stages.[].thrust.[].environment:string                     "vacuum"
stages.[].thrust.[].magnitude:number                       6672
stages.[].thrust.[].units:string                           "kN"
stages.[].name:string                                      "second"
stages.[].purpose:string                                   "thrust"
stages.[].number:number                                    2
stages.[].inhabitable:boolean                              FALSE
stages.[].engines:number                                   1
stages.[].burn_time:number                                 375
stages.[].thrust.[].environment:string                     "vacuum"
stages.[].thrust.[].magnitude:number                       801
stages.[].thrust.[].units:string                           "kN"
stages.[].name:string                                      "interstage"
stages.[].purpose:string                                   "separation"
stages.[].number:number                                    3
stages.[].inhabitable:boolean                              FALSE
stages.[].engines:null                                     TRUE
stages.[].notes:string                                     "pneumatic release"
stages.[].name:string                                      "payload"
stages.[].purpose:string                                   "payload"
stages.[].number:number                                    4
stages.[].inhabitable:boolean                              TRUE
```

The key underpinnings of text indexes is how they're translated to be stored in the Lucene
indexes. This uses a standard approach to breaking a JSON document into a list of key/value
pairs where the key is a dotted path and the value is either `null`, `true`, `false`, a string, or
number.

The paths used for keys are fairly standard with a notable exception for arrays. Perhaps
the easiest way to explain is by example.

There are a couple of things that should immediately stick out. Each field name ends up with its type
appended to the end. This means if two documents that both have a field named `"zipcode"`
where one document has a value `68130` and another document has the value `"68130-2579"`
(notice that is a number first and string second) the end result will be an index with two different
fields, one named `zipcode:number` and one named `zipcode:string`.

Most of the time this type distinction can be hidden from the user. In general we can infer types
in selectors and so on. Occasionally though we require that the user must specify a type
manually. The most important place for this is probably when specifying a sort. We do attempt
to inspect the selector but if the selector either contains the same field with multiple types, or
doesn't contain the field at all then we return an error instructing the user to specify the type.

Along with indexes over all the fields there are two other important fields that are generated. The
first is a `$default` field which contains all of the string values using the `default_field`
analyzer for indexing. This can currently be disabled but that may or may not be something
we'll want to keep as an option. This field is only ever used for the `$text` operator's default
field.

The second important default index is the `$fieldnames` index. This index contains the
complete list of field names for each document. We rely heavily on this index to support some
specific queries. For instance, the `$exists` operator can make obvious use of this index by
specifying a query like `$fieldnames:stages.[].thrust` which would return every document
with a field named `stages` that contains an array that has at least one object with the key
`thrust`.

The only other thing to note is that we escape all field names with a url-escape-like approach.
Although rather than use the `%` character we use `_` and aggressively escape any non-
alphanumeric bytes.

### Index Lookup Post-Filtering

> Example document

```json
{
  "_id": "washer",
  "contents": [
    {
      "type": "shirt",
      "color": "red",
      "size": "large"
    }
  ]
}
```

> Exploded field/value list

```
_id:string                "washer"
contents.[].color:string  "red"
contents.[].size:string   "large"
contents.[].type:string   "shirt"
```

> Example document

```json
{
  "_id": "dresser",
  "contents": [
    {
      "type": "socks",
      "color": "red",
      "size": "small"
    },
    {
      "type": "pants",
      "color": "blue",
      "size": "medium"
    },
    {
      "type": "shirt",
      "color": "black",
      "size": "large"
    }
  ]
}
```

> Exploded field/value list

```
_id:string                  "dresser"
contents.[].color:string    "black"
contents.[].color:string    "blue"
contents.[].color:string    "red"
contents.[].size:string     "large"
contents.[].size:string     "medium"
contents.[].size:string     "small"
contents.[].type:string     "pants"
contents.[].type:string     "shirt"
contents.[].type:string     "socks"
```

As the astute observer will have noticed there are a number of queries that are not directly
answerable using the given scheme described above. A good example would be searching
using the `$elemMatch` operator which applies to objects in arrays. Given that we erase array
position of fields we are unable to determine the difference between field names originating from
separate elemnts. Consider a search for large red shirts with the following documents:


Because of the way the conversion to field/value pairs is done, there is no way to tell whether any particular field value came from a specific element of
an array. Instead, the approach taken is to ensure that all documents  - including false
positives - are returned by the initial index lookup and then apply a filtering step to make sure only the right documents are returned. The key here is to
always ensure that queries don't have false *negatives* at the expense of filtering out the possible false positives.

With the post-lookup filtering, searching for large red shirts is possible by
returning both documents from the index and discarding the dresser document.

### Selector Translation

> Example query to be translated

```json
{"age": {"$gt": 5}}
```

> Lucene query

```
(age_3anumber:{5 TO Infinity])
```

Lucene does not understand Cloudant's JSON based query syntax out of the box, so we have
to translate between the two formats. We translate from Cloudant's JSON selector syntax to
the Lucene query parser syntax.

Here we can see the straighforward translation. We note that this translates to English as, "age
as a number greater than five and less than or equal to infinity". The _3a is an example of the
fieldname escaping we mentioned earlier.

#### A more complex example

> JSON query to be translated

```json
{
  "$or": [
  {"age": {"$gt": 5}},
  {"twitter":{"$exists":true}},
  {"type": {"$in": [
    "starch",
    "protein"
  ]}}
  ]
}
```

> Lucene query for age > 5

```
(
(age_3anumber:{5 TO Infinity])
```

> Lucene query for documents containing the twitter field

```
(($fieldnames:twitter_3a*) OR ($fieldnames:twitter_2e*))
```

> Lucene query for type = starch

```
(
((type_3astring:starch) OR (type_2e_5b_5d_3astring:starch))
```

> Lucene query for type = protein

```
((type_3astring:protein) OR (type_2e_5b_5d_3astring:protein))
)
)
```

Here there are a couple interesting things to note. First, for the `{"$exists":true}` query we
get a two clause OR query for the `twitter` field that ends in `_3a*` and `_2e*`. This clause is
searching the `$fieldnames` field for entries that contain either `twitter.*` or `twitter:*` . The
reason for this is so that we can match when the value is an array or object. This is implemented
as two phrases instead of a single `twitter*` query to ensure that we don't accidentally match
a field names `twitter_handle` or similar.

The last of the three main clauses is bit more complicated yet. The `$in` operator has some
special semantics for array values that we inherited from MongoDB's documented behavor.
Namely, that `$in` applies to the value **OR** any of the values contained in an array named by the
given field. Thus, in our example both `"type":"starch"` **AND** `"type":["protein"]` would
match the exampe argument to `$in` . By now we can see that `type_3astring` translates to
`type:string`, where as the second `type_2e_5b_5d_3astring` translatse to `type`.
`[]:string` which is an example of how we leverage our decimated array indexing.

It should be noted that the current system of tranlsating to Lucene's QueryParser syntax is
actually bit of a weak link in our system. This is due to the requirement that we match the
escaping semantics of the QueryParser exactly so that values are passed through Lucene's
analyzers correctly. A future improvement will be to upgrade the Cloudant Search infrastructure
to accept a JSON description of the query that will then be directly translated into Lucene's
query objects rathern than having to serialize through the QueryParser syntax.

