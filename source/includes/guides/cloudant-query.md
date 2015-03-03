## Cloudant Query Text Indexes

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

```
curl -X PUT https://user.cloudant.com/dbname
```

<div id="step02"></div>
#### 2. Create a text index

> Example command to create a text index within the database:

```
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_index \
  -d '{"index":{}, "type": "text"}'
```

<div id="step03"></div>
#### 3. Add a document

> Example command to create a simple document:

```
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname \
  -d '{"character":"Frodo Baggins", "type": "Hobbit", "height":4}'
```

<div id="step04"></div>
#### 4. Query for the document

> Example command to query for a document that matches text precisely:

```
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_find \
  -d '{"selector":{"$text": "Frodo"}}'
```

> Example command to query for a document that matches a condition:

```
curl -X POST -H "Content-Type: application/json" \
  https://user.cloudant.com/dbname/_find \
  ￼-d '{"selector":{"$or": [{"type":"Orc"}, {"height": {"$lt":4.5}}]}'
```

### Working with real data

> Obtaining a copy of the Cloudant Query movie database:

```
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

```
{"ok":true,"use_checkpoints":false}
```

To describe FTI, it is helpful to have a large collection of data to work with.
A suitable collection is available in the example Cloudant Query movie database: `movies-demo`.
You can obtain a copy of this database in your database, with the name `my-movies-demo`,
by running the command shown.

The sample database contains approximately 3,000 documents, and is just under 1 MB in size.

<div></div>

> Creating a _text_ index for your sample database:

```
curl 'https://<user:password>@<user>.cloudant.com/my-movies-demo/_index' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"index": {}, "type": "text"}'
```

> Response after creating a text index:

```
{"result":"created"}
```

Before we can search the content, we must index it. We do this by creating a text index for the documents.
<aside class="notice">We do not index any specific field, we do not need to provide and index name, and the index type is `text`.</aside>

<div></div>

> Searching for a specific document within the database:

```
curl -X POST -H "Content-Type: application/json" \
        https://<user:password>@<user>.cloudant.com/my-movies-demo/_find \
        -d '{"selector": {"Person_name":"Zoe Saldana"}}'
```

> Example result from the search:

```
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

```
curl -X POST -H "Content-Type: application/json" \
        https://<user:password>@<user>.cloudant.com/my-movies-demo/_find \
        -d '{"selector": {"Person_name":"Robert De Niro", "Movie_year": 1978}}'
```

> Example result from the search:

```
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