## Cloudant Query Text Indexes

Cloudant Query has support for [creating indexes](api.html#creating-a-new-index)
using [Apache Lucene](http://lucene.apache.org/).
This capability provides several benefits, including:

-	Full Text Indexing
-	Arbitrary queries

This guide describes the featutes, and explains how to use them.

### Overview

To get the benefits from Full Text Indexing,
you should already be familiar with the basics of using Cloudant.

There are four basic steps to work with Full Text Indexing:

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

To describe Full Text Indexing, it is helpful to have a large collection of data to work with.
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
  -d '{
    "index": {
    },
    "name" : "Person_name-index",
    "type" : "text"
}'
```

Before we can search the content, we must index it. We do this by creating an index for the documents.
In our example, we create an index called `Person_name-index`.
Notice that we do not index any specific field, and also that the index type is `text`.

<div></div>

> Searching for a specific document within the database:

```
curl -X POST -H "Content-Type: application/json" \
        https://warmana:QESX8kvw7NxCMTgA@warmana.cloudant.com/my-movies-demo/_find \
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
  ]
}
```