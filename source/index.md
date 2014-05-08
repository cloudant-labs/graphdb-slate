---
title: Documentation

language_tabs:
  - shell
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
  - api
  - account
  - authentication
  - authorization
  - database
  - document
  - attachments
  - design_documents
  - search
  - mapreduce
  - geo
  - replication
  - advanced
  - errors

---

# Documentation

Cloudant provides reliable [database](#databases) hosting and support for applications of any scale. It’s available to users within minutes of [creating an account](https://cloudant.com/sign-up/) because there’s nothing to install. This documentation contains [more detail about Cloudant](#why_cloudant), [the technology which supports it](#no_SQL), and [API reference](#api-reference) for developers.

Cloudant encourages contributions and suggestions for improvement to this page. Contributions can be made through [GitHub](https://github.com/cloudant-labs/slate). Support is available to users through their dashboard and within a dedicated community on [StackOverflow](http://stackoverflow.com/questions/tagged/cloudant).

## Who are we?

Cloudant is a Massachusetts-based company, with offices in Seattle and Bristol, UK. Cloudant is a division of IBM. You can get in touch with us via [email](mailto:support@cloudant.com) or check out our [calendar](#) of conferences and events to start a conversation in person.

# Why Cloudant?

<div id="why_cloudant"></div>

Cloudant is the name of both the provider and the service, in this case a [database-as-a-service](https://cloudant.com/product/comparison-of-dbaas/), commonly known as DBaaS. It does not use [SQL](#no_SQL) as its query language and it’s [distributed over the web](#distributed), all features which you can read about in more depth within this documentation. You can use Cloudant for [almost any purpose](https://cloudant.com/terms/) in any scale of application.

## NoSQL Databases

<div id="no_SQL"></div>

Cloudant databases do not use SQL to query, trading eventual consistency for unparalleled scalability. Cloudant stores documents using JSON (JavaScript Object Notion) encoding, so anything encoded into JSON can be stored as a document. Files like images, videos, and audio are called BLObs (binary large objects) and can be stored as attachments within documents.

## HTTP-Driven

<div id="http_driv"></div>

All requests to Cloudant go over the web, which means any system that can speak to the web, can speak to Cloudant. All language-specific libraries for Cloudant are really just wrappers that provide some convenience and linguistic niceties to what, under the hood, is a pretty simple API. Many users even choose to use raw HTTP libraries for working with Cloudant.

## Distributed

<div id="distributed"></div>

Cloudant's API represents the collaboration of numerous machines, called a cluster, which may live in different physical locations. Clustering means that when you need more horsepower, you just add more machines, which is more cost-effective and fault-tolerant than scaling up a single machine.

### The CAP Theorem

<div id="cap_theorem"></div>

Developers early in the design process might want to consider the complexities raised by The CAP theorem, which states that a distributed computing system can only exhibit two of the three following characteristics:

* Consistency: all nodes see the same data at the same time.
* Availability: every request receives a response indicating success or failure.
* Partition Tolerance: the system continues to operate despite arbitrary message loss or failure of part of the system.

For example, a database prioritizing consistency and availability is simple: a single node storing a single copy of your data. But scaling necessarily involves a performance increase in the node rather than the leverage of additional nodes, which means that a minor system failure can shut down a single-node system. To endure, the system must become more sophisticated. Cloudant's ease of scalability makes it adaptable to this problem.

The formal proof for the CAP theroem is available [here](http://lpd.epfl.ch/sgilbert/pubs/BrewersConjecture-SigAct.pdf) for a more in depth view.

## AcID

<div id="acid"></div>

ACID is an acronym for [atomic](#acid_atomic), [consistent](#acid_consistent), [isolated](#acid_isolated), [durable](#acid_durable), simply a set of properties which guarantee that transactions with a database are processed and reported reliably. Cloudant is AcID: the “c” is lowercase because Cloudant is eventually consistent rather than strongly consistent.

### Atomic

<div id="acid_atomic"></div>

Atomic is just another way to mean “cannot be divided”. All this means is that if one part of a process fails, the whole thing fails, so that the database is not left in an inconsistent state. For example, a request to modify a document will only report success once it has been written to disk.

### Consistent

<div id="acid_consistent"></div>

Cloudant is eventually consistent, such that any change will propagate to the whole cluster within milliseconds, but will not wait for that propagation before reporting success. 

### Isolated

<div id="acid_isolated"></div>

Cloudant is lockless, so that even simultaneous reads and writes will not delay or impact other reads and writes. Isolation just means that concurrent processes like this result in a state that would be obtained if things happened one at a time.

### Durable

<div id="acid_durable"></div>

Durability ensures that changes remain once committed, even with power failures or other errors. Document updates and insertions are written to disk before the request is considered complete.

## Replication

<div id="replication"></div>

Replication is a procedure followed by Cloudant, [CouchDB](http://couchdb.apache.org/), [PouchDB](http://junk.arandomurl.com/), and others. It synchronizes the state of two databases so that their contents are identical. You can continuously replicate as well, which means that a target database updates every time the source changes. This can be used for backups of data, aggregation across multiple databases, or for sharing data.
