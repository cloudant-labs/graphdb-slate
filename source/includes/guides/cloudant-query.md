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

