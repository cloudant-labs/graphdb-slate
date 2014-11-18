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

[Replication](#replication102) is a procedure followed by Cloudant, [CouchDB](http://couchdb.apache.org/), [PouchDB](http://junk.arandomurl.com/), and others. It synchronizes the state of two databases so that their contents are identical. You can continuously replicate as well, which means that a target database updates every time the source changes. This can be used for backups of data, aggregation across multiple databases, or for sharing data.

Request Methods
---------------

Cloudant supports the following HTTP request methods:

-   `GET`

    Request the specified item. As with normal HTTP requests, the format of the URL defines what is returned. With Cloudant this can include static items, database documents, and configuration and statistical information. In most cases the information is returned in the form of a JSON document.

-   `HEAD`

    The `HEAD` method is used to get the HTTP header of a `GET` request without the body of the response.

-   `POST`

    Upload data. Within Cloudant's API, `POST` is used to set values, including uploading documents, setting document values, and starting certain administration commands.

-   `PUT`

    Used to put a specified resource. In Cloudant's API, `PUT` is used to create new objects, including databases, documents, views and design documents.

-   `DELETE`

    Deletes the specified resource, including documents, views, and design documents.

-   `COPY`

    A special method that can be used to copy documents and objects.

If the client (such as some web browsers) does not support using these HTTP methods, `POST` can be used instead with the `X-HTTP-Method-Override` request header set to the actual HTTP method.

### Method not allowed error

``` sourceCode
{
    "error":"method_not_allowed",
    "reason":"Only GET,HEAD allowed"
}
```

If you use an unsupported HTTP request type with a URL that does not support the specified type, a 405 error will be returned, listing the supported HTTP methods. For example:

HTTP Headers
------------

Because Cloudant uses HTTP for all external communication, you need to ensure that the correct HTTP headers are supplied (and processed on retrieval) so that you get the right format and encoding. Different environments and clients will be more or less strict on the effect of these HTTP headers (especially when not present). Where possible you should be as specific as possible.

### Request Headers

#### Content-Type

    Specifies the content type of the information being supplied within the request. The specification uses MIME type specifications. For the majority of requests this will be JSON (`application/json`). For some settings the MIME type will be plain text. When uploading attachments it should be the corresponding MIME type for the attachment or binary (`application/octet-stream`).

    The use of the `Content-type` on a request is highly recommended.

#### Accept

> For example, when sending a request without an explicit `Accept` header, or when specifying `*/*`:

```http
GET /recipes HTTP/1.1
Host: username.cloudant.com
Accept: */*
```

> The returned headers are:

```
Server: CouchDB/1.0.2 (Erlang OTP/R14B)
Date: Thu, 13 Jan 2011 13:39:34 GMT
Content-Type: text/plain;charset=utf-8
Content-Length: 227
Cache-Control: must-revalidate
```

> Note that the returned content type is `text/plain` even though the information returned by the request is in JSON format.

> Explicitly specifying the `Accept` header:

```http
GET /recipes HTTP/1.1
Host: username.cloudant.com
Accept: application/json
```

> The headers returned include the `application/json` content type:

```
Server: CouchDB/1.0.2 (Erlang OTP/R14B)
Date: Thu, 13 Jan 2011 13:40:11 GMT
Content-Type: application/json
Content-Length: 227
Cache-Control: must-revalidate
```


Specifies the list of accepted data types to be returned by the server (i.e. that are accepted/understandable by the client). The format should be a list of one or more MIME types, separated by colons.

For the majority of requests the definition should be for JSON data (`application/json`). For attachments you can either specify the MIME type explicitly, or use `*/*` to specify that all file types are supported. If the `Accept` header is not supplied, then the `*/*` MIME type is assumed (i.e. client accepts all formats).

The use of `Accept` in queries to Cloudant is not required, but is highly recommended as it helps to ensure that the data returned can be processed by the client.

If you specify a data type using the `Accept` header, Cloudant will honor the specified type in the `Content-type` header field returned. For example, if you explicitly request `application/json` in the `Accept` of a request, the returned HTTP headers will use the value in the returned `Content-type` field.

#### If-None-Match

This header can optionally be sent to find out whether a document has been modified since it was last read or updated. The value of the `If-None-Match` header should match the last `Etag` value received. If the value matches the current revision of the document, the server sends a `304 Not Modified` status code and the response will not have a body. If not, you should get a normal 200 response, provided the document still exists and no other errors occur.

### Response Headers

Response headers are returned by the server when sending back content and include a number of different header fields, many of which are standard HTTP response header and have no significance to how Cloudant operates. The list of response headers important to Cloudant are listed below.

The Cloudant design document API and the functions when returning HTML (for example as part of a show or list) enable you to include custom HTTP headers through the `headers` field of the return object.

#### Content-Type

Specifies the MIME type of the returned data. For most request, the returned MIME type is `text/plain`. All text is encoded in Unicode (UTF-8), and this is explicitly stated in the returned `Content-type`, as `text/plain;charset=utf-8`.

#### Cache-Control

The cache control HTTP response header provides a suggestion for client caching mechanisms on how to treat the returned information. Cloudant typically returns the `must-revalidate`, which indicates that the information should be revalidated if possible. This is used to ensure that the dynamic nature of the content is correctly updated.

#### Content-Length

    The length (in bytes) of the returned content.

#### Etag

The `Etag` HTTP header field is used to show the revision for a document or the response from a show function. For documents, the value is identical to the revision of the document. The value can be used with an `If-None-Match` request header to get a `304 Not Modified` response if the revision is still current.

ETags cannot currently be used with views or lists, since the ETags returned from those requests are just random numbers that change on every request.


HTTP Status Codes
-----------------

With the interface to Cloudant working through HTTP, error codes and statuses are reported using a combination of the HTTP status code number, and corresponding data in the body of the response data.

A list of the error codes returned by Cloudant and generic descriptions of the related errors are provided below. The meaning of different status codes for specific request types are provided in the corresponding API call reference.

-   `200 - OK`

    Request completed successfully.

-   `201 - Created`

    Resource created successfully.

-   `202 - Accepted`

    Request has been accepted, but the corresponding operation may not have completed. This is used for background operations, such as database compaction or for bulk operations where some updates might have led to a conflict.

-   `304 - Not Modified`

    The content requested has not been modified. This is used with the ETag system to identify the version of information returned.

-   `400 - Bad Request`

    Bad request structure. The error can indicate an error with the request URL, path or headers. Differences in the supplied MD5 hash and content also trigger this error, as this may indicate message corruption.

-   `401 - Unauthorized`

    The item requested was not available using the supplied authorization, or authorization was not supplied.

-   `403 - Forbidden`

    The requested item or operation is forbidden.

###### 404

```json
{"error":"not_found","reason":"no_db_file"}
```
-   `404 - Not Found`

    The requested resource could not be found. The content will include further information, as a JSON object, if available. The structure will contain two keys, `error` and `reason`. For example:

-   `405 - Resource Not Allowed`

    A request was made using an invalid HTTP request type for the URL requested. For example, you have requested a `PUT` when a `POST` is required. Errors of this type can also be triggered by invalid URL strings.

-   `406 - Not Acceptable`

    The requested content type is not supported by the server.

-   `409 - Conflict`

    Request resulted in an update conflict.

-   `412 - Precondition Failed`

    The request headers from the client and the capabilities of the server do not match.

-   `415 - Bad Content Type`

    The content types supported, and the content type of the information being requested or submitted indicate that the content type is not supported.

-   `416 - Requested Range Not Satisfiable`

    The range specified in the request header cannot be satisfied by the server.

-   `417 - Expectation Failed`

    When sending documents in bulk, the bulk load operation failed.

-   `500 - Internal Server Error`

    The request was invalid, either because the supplied JSON was invalid, or invalid information was supplied as part of the request.

JSON Basics
-----------

The majority of requests and responses to and from Cloudant use the JavaScript Object Notation (JSON) for formatting the content and structure of the data and responses.

JSON is used because it is the simplest and easiest to use solution for working with data within a web browser, as JSON structures can be evaluated and used as JavaScript objects within the web browser environment. JSON also integrates with the server-side JavaScript used within Cloudant. JSON documents are always UTF-8 encoded.

### Warning

Care should be taken when comparing strings in JSON documents retrieved from Cloudant. Unicode normalization might have been applied, so that a string stored and then retrieved is not identical on a binary level. To avoid this problem, always normalize strings before comparing them.

JSON supports the same basic types as supported by JavaScript:


### Numbers

```json
123
```

Numbers can be integer or floating point values.

### Strings

```json
"A String"
```

String should be enclosed by double-quotes. They support Unicode characters and backslash escaping.

### Booleans

A `true` or `false` value.

```json
{ "value": true}
```

### Arrays

```json
["one", 2, "three", [], true, {"foo": "bar"}]
```

A list of values enclosed in square brackets. The values enclosed can be any valid json.


### Objects

```json
{
   "servings" : 4,
   "subtitle" : "Easy to make in advance, and then cook when ready",
   "cooktime" : 60,
   "title" : "Chicken Coriander"
}
```

A set of key/value pairs (i.e. an associative array, or hash). The key must be a string, but the value can be any of the supported JSON values.

In Cloudant databases, the JSON object is used to represent a variety of structures, including all documents in a database.

Parsing JSON into a JavaScript object is supported through the `JSON.parse()` function in JavaScript, or through various libraries that will perform the parsing of the content into a JavaScript object for you. Libraries for parsing and generating JSON are available in all major programming languages.

### Warning

Care should be taken to ensure that your JSON structures are valid, invalid structures will cause Cloudant to return an HTTP status code of 400 (bad request).


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
