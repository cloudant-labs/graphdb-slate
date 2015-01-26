# ![alt tag](images/cloudantbasics_icon.png) Cloudant Basics

If it's your first time here, scan this section before you scroll further. The sections on [Client Libraries](libraries.html#-client-libraries), [API Reference](api.html#-api-reference), and [Guides](guides.html#-guides) assume you know basic things about Cloudant.

<div id="consistency"></div>
## Consistency

Cloudant uses an '[Eventually Consistent](http://en.wikipedia.org/wiki/Eventual_consistency)' model. To understand how this works, and why it is an essential part of using Cloudant, we must first consider what is meant by Consistency.

Consistency is one of the three attributes in the [CAP theorem](./guides.html#cap_theorem), which states that it is not possible for a distributed computer system - such as Cloudant - to simultaneously guarantee three attributes:

- Consistency, where all nodes see the same data at the same time.
- Availability, which guarantees that every request receives a response about whether it succeeded or failed.
- Partition tolerance, where the system continues to operate even if any one part of the system is lost or fails.

The impossibility of guaranteeing all three attributes means that Cloudant does not guarantee the Consistency attribute. In an eventually consistent model, like Cloudant, an update made to one part of the system is *eventually* seen by other parts of the system. As the update propagates, the system is said to 'converge' on complete consistency.

Eventual consistency is good for performance. With a strong consistency model, a system would have to wait for any updates to propagate completely and successfully before a write or update request could be completed. With an eventually consistent model, the write or update request can return almost immediately, while the propagation across the system continues 'behind the scenes'.


<div id="json"></div>
## JSON
Cloudant stores documents using JSON (JavaScript Object Notion) encoding, so anything encoded into JSON can be stored as a document. Files like images, videos, and audio are called BLObs (binary large objects) and can be stored as attachments within documents.

<div id="http_api"></div>
## HTTP API
All requests to Cloudant go over the web, which means any system that can speak to the web, can speak to Cloudant. All language-specific libraries for Cloudant are really just wrappers that provide some convenience and linguistic niceties to help you work with a simple API. Many users even choose to use raw HTTP libraries for working with Cloudant.

<div id="distributed"></div>
## Distributed
Cloudant's API enables you to interact with a collaboration of numerous machines, called a cluster. The machines in a cluster must be in the same datacenter, but can be within different 'pods' in that datacenter. Using different pods helps improve the High Availability characteristics of Cloudant.

An advantage of clustering is that when you need more computing capacity, you just add more machines. This is often more cost-effective and fault-tolerant than scaling up or enhancing an existing single machine.

<div id="replication"></div>
## Replication

[Replication](api.html#ReplicationAPI) is a procedure followed by Cloudant, [CouchDB](http://couchdb.apache.org/), [PouchDB](http://pouchdb.com/), and others. It synchronizes the state of two databases so that their contents are identical.

You can continuously replicate. This means that a target database updates every time the source database changes. Testing for source changes involves ongoing internal calls.
Continuous replication can be used for backups of data, aggregation across multiple databases, or for sharing data.

<aside class="warning">Continuous replication can result in a large number of internal calls. This might affect costs for multi-tenant users of Cloudant systems. Continuous replication is disabled by default.</aside>

## Request Methods

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

> error message

```json
{
    "error":"method_not_allowed",
    "reason":"Only GET,HEAD allowed"
}
```

If you use an unsupported HTTP request type with a URL that does not support the specified type, a 405 error will be returned, listing the supported HTTP methods. For example:

## HTTP Headers

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

<div></div>
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

## HTTP Status Codes

With the interface to Cloudant working through HTTP, error codes and statuses are reported using a combination of the HTTP status code number, and corresponding data in the body of the response data.

A list of the error codes returned by Cloudant and generic descriptions of the related errors are provided below. The meaning of different status codes for specific request types are provided in the corresponding API call reference.

-   `200 - OK`

    Request completed successfully.

-   `201 - Created`

    Resource created or updated successfully. The resource could be a database or a document, for example.

-   `202 - Accepted`

    Request has been accepted, but the corresponding operation may not have completed. This is used for background operations, such as database compaction or for bulk operations where some updates might have led to a conflict. This code can also be returned following an attempt to create or update a document.

-   `304 - Not Modified`

    The content requested has not been modified. This is used with the ETag system to identify the version of information returned.

<div id="400"></div>

-   `400 - Bad Request`

    Bad request structure. The error can indicate an error with the request URL, path or headers. Differences in the supplied MD5 hash and content also trigger this error, as this may indicate message corruption.

-   `401 - Unauthorized`

    The item requested was not available using the supplied authorization, or authorization was not supplied.

-   `403 - Forbidden`

    The requested item or operation is forbidden.

<div id="404"></div>

> Example detail supplied in JSON format, following 404 status code:

```
{
  "error":"not_found",
  "reason":"no_db_file"
}
```

-   `404 - Not Found`

    The requested resource could not be found. The content includes further information as a JSON object, if available. The structure contains two keys, `error` and `reason`.

<div id="405"></div>

-   `405 - Resource Not Allowed`

    A request was made using an invalid HTTP request type for the URL requested. For example, you have requested a `PUT` when a `POST` is required. Errors of this type can also be triggered by invalid URL strings.

-   `406 - Not Acceptable`

    The requested content type is not supported by the server.

<div id="409"></div>

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

<div id="503"></div>

-   `503 - Service Unavailable`

    The request could not be processed. Seeing this response following a Cloudant request might indicate an misspelled Cloudant account name. 

## JSON Basics

The majority of requests and responses to and from Cloudant use the JavaScript Object Notation (JSON) for formatting the content and structure of the data and responses.

JSON is used because it is the simplest and easiest solution for working with data using a web browser.
This is because JSON structures can be evaluated and used as JavaScript objects within the web browser environment. JSON also integrates with the server-side JavaScript used within Cloudant. JSON documents are always UTF-8 encoded.

<aside class="warning">Care should be taken to ensure that:

-  Your JSON structures are valid. Invalid structures cause Cloudant to return an HTTP status code of [400 (bad request)](#400).
-  You normalize strings in JSON documents retrieved from Cloudant, before you compare them. This is because Unicode normalization might have been applied, so that a string stored and then retrieved is not identical on a binary level.

</aside>

JSON supports the same basic types as supported by JavaScript:

- [Numbers](#numbers)
- [Strings](#strings)
- [Booleans](#booleans)
- [Arrays](#arrays)
- [Objects](#objects)

### Numbers

> numbers

```json
123
```

Numbers can be integer or floating point values.

### Strings

> strings

```json
"A String"
```

String should be enclosed by double-quotes. Strings support Unicode characters and backslash escaping.

### Booleans

> booleans

```json
{ "value": true}
```

A `true` or `false` value.

### Arrays

> arrays

```json
["one", 2, "three", [], true, {"foo": "bar"}]
```

A list of values enclosed in square brackets. The values enclosed can be any valid JSON.


### Objects

> objects

```json
{
   "servings" : 4,
   "subtitle" : "Easy to make in advance, and then cook when ready",
   "cooktime" : 60,
   "title" : "Chicken Coriander"
}
```

A set of key/value pairs, such as an associative array, or hash. The key must be a string, but the value can be any of the supported JSON values.

In Cloudant databases, the JSON object is used to represent a variety of structures, including all documents in a database.

Parsing JSON into a JavaScript object is supported through the `JSON.parse()` function in JavaScript, or through various [libraries](libraries.html#-client-libraries) that perform the parsing of the content into a JavaScript object for you. [Libraries](libraries.html#-client-libraries) for parsing and generating JSON are available for many major programming languages.

## Cloudant Local

<a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH/SSTPQH_welcome.html" target="_blank">IBM Cloudant Data Layer Local Edition (Cloudant Local)</a> is a locally installed version of the Cloudant Database-as-a-Service (DBaaS) offering.

Cloudant Local provides you with the same basic capabilities as the full Cloudant single-tenant offering,
but hosted within your own data center installation.

A more detailed overview of Cloudant Local is <a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH_1.0.0/com.ibm.cloudant.local.install.doc/topics/clinstall_cloudant_local_overview.html?lang=en-us" target="_blank">available</a>.

The <a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH_1.0.0/com.ibm.cloudant.local.doc/SSTPQH_1.0.0_welcome.html?lang=en" target="_blank">IBM Knowledge Center</a> provides information on many aspects of Cloudant Local,
including:

- <a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH_1.0.0/com.ibm.cloudant.local.install.doc/topics/clinstall_install_configure_cloudant_local.html?lang=en" target="_blank">Installation and Configuration</a>
- <a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH_1.0.0/com.ibm.cloudant.local.install.doc/topics/clinstall_maintenance_tasks_overview.html?lang=en" target="_blank">Maintenance Tasks</a>
- <a href="http://www-01.ibm.com/support/knowledgecenter/SSTPQH_1.0.0/com.ibm.cloudant.local.install.doc/topics/clinstall_tuning_parameters_replication_cases.html?lang=en" target="_blank">Tuning replication parameters</a>
