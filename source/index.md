---
title: Cloudant Documentation

language_tabs:
  - http
  - shell: curl
  - javascript: node.js
  - python

toc_footers:
  - <a href="https://cloudant.com/">Cloudant</a>
  - <a href="https://cloudant.com/sign-up/">Sign up</a> / <a href="https://cloudant.com/sign-in/">Sign in</a>
  - <a href="http://stackoverflow.com/questions/tagged/cloudant">Cloudant on StackOverflow</a>
  - <a href="http://webchat.freenode.net/?channels=cloudant">Cloudant on IRC</a>
  - <a href="mailto:support@cloudant.com">Email Support</a>
  - <a href='http://github.com/tripit/slate'>Documentation Powered by Slate</a>
  - <a href="https://github.com/cloudant-labs/slate">Documentation Source</a>

includes:
  - api/index
  - api/account
  - api/authentication
  - api/authorization
  - api/database
  - api/document
  - api/attachments
  - api/design_documents
  - api/search
  - api/mapreduce
  - api/geo
  - api/replication
  - api/advanced
  - api/errors
  - guides/index
  - guides/mvcc
  - guides/transactions
  - guides/cap_theorum
  - guides/acid
  - libraries/index

---

# Documentation

This is the online documentation for the [Cloudant database-as-a-service](https://cloudant.com/). Here you'll find a quick overview of Cloudant Basics, our API Reference, Client Libraries to help you get going quickly, and Guides that explore more advanced concepts in detail.

## Contribute
Cloudant is built on best-of-breed open source technologies, and we're heavy committers to the technology we rely on. We're also open about our documentation. If it's not working for you, it's not working for us. Please make contributions or share suggestions on [GitHub](https://github.com/cloudant-labs/slate).


<div id="why_cloudant"></div>
# Cloudant Basics

If it's your first time here, scan this section before you scroll further. The API Reference, Client Libraries and Guides that follow assume you know these things about Cloudant.

<div id="json"></div>
## JSON
Cloudant stores documents using JSON (JavaScript Object Notion) encoding, so anything encoded into JSON can be stored as a document. Files like images, videos, and audio are called BLObs (binary large objects) and can be stored as attachments within documents.

<div id="http_api"></div>
## HTTP API
All requests to Cloudant go over the web, which means any system that can speak to the web, can speak to Cloudant. All language-specific libraries for Cloudant are really just wrappers that provide some convenience and linguistic niceties to what, under the hood, is a pretty simple API. Many users even choose to use raw HTTP libraries for working with Cloudant.

<div id="distributed"></div>
## Distributed
Cloudant's API represents the collaboration of numerous machines, called a cluster, which may live in different physical locations. Clustering means that when you need more horsepower, you just add more machines, which is more cost-effective and fault-tolerant than scaling up a single machine.

<div id="replication"></div>
## Replication

Replication is a procedure followed by Cloudant, [CouchDB](http://couchdb.apache.org/), [PouchDB](http://junk.arandomurl.com/), and others. It synchronizes the state of two databases so that their contents are identical. You can continuously replicate as well, which means that a target database updates every time the source changes. This can be used for backups of data, aggregation across multiple databases, or for sharing data.

## Client Libraries

If you're working in one of the following languages, we highly recommend these libraries for working with Cloudant. If you see that one you like isn't mentioned, [let us know!](https://github.com/cloudant-labs/slate/issues).

### Node.js

[Nano](https://github.com/dscape/nano) is a minimalistic client for CouchDB and Cloudant. You can install it via NPM:

```
npm install nano
```

### JavaScript

[PouchDB](http://pouchdb.com/) is a JavaScript database that can sync with Cloudant, meaning you can make your apps offline-ready just by using PouchDB. For more info, see [our blog post](https://cloudant.com/blog/pouchdb) on PouchDB, or install it by including this in your app's HTML:

```html
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/pouchdb/2.2.0/pouchdb.min.js"></script>
```

PS: PouchDB is also available for Node.js: `npm install pouchdb`

### Python

[Cloudant-Python](https://github.com/cloudant-labs/cloudant-python) is Cloudant's premier Python client. Install it using pip:

```
pip install cloudant
```

### Ruby

[CouchRest](https://github.com/couchrest/couchrest) is a CouchDB and Cloudant client with extensions for working with Rails using [CouchRest Model](https://github.com/couchrest/couchrest_model).

```
gem install couchrest
```

### PHP

[Sag](http://www.saggingcouch.com/) is PHP's CouchDB and Cloudant client. [Sag.js](https://github.com/sbisbee/sag-js) is Sag's JavaScript counterpart.

```
// download sag from http://www.saggingcouch.com/download.php
require_once('./src/Sag.php');
```

### C# / .NET

[MyCouch](https://github.com/danielwertheim/mycouch) is an asynchronous CouchDB and Cloudant client for .Net.

```
/// open up the Package manager console, and invoke:
install-package mycouch.cloudant
```

### Java

[Ektorp](https://github.com/helun/Ektorp) is a Java API for CouchDB and Cloudant.

```
// install binaries from https://github.com/helun/Ektorp/downloads
// or, if using maven, set this in your dependencies:
<dependency>
    <groupId>org.ektorp</groupId>
    <artifactId>org.ektorp</artifactId>
    <version>1.3.0</version>
</dependency>
```
