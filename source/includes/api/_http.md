## HTTP

This section provides details of the [HTTP Headers](#http-headers) and [HTTP Status Codes](#http-status-codes) you need to know when using Cloudant.

### HTTP Headers

Because Cloudant uses HTTP for all external communication, you need to ensure that the correct HTTP request headers are supplied and processed on retrieval.
This is to ensure that you get the right format and encoding. Different environments and clients are more or less strict on the effect of these HTTP headers, especially when they are not present.
Where possible, you should be as specific as possible.

#### Request headers

##### Content-Type

Specifies the content type of the information being supplied within the request. The specification uses MIME type specifications. For the majority of requests this will be JSON (`application/json`). For some settings the MIME type will be plain text. When uploading attachments it should be the corresponding MIME type for the attachment or binary (`application/octet-stream`).

The use of the `Content-type` on a request is highly recommended.

##### Accept

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
##### If-None-Match

This header can optionally be sent to find out whether a document has been modified since it was last read or updated. The value of the `If-None-Match` header should match the last `Etag` value received. If the value matches the current revision of the document, the server sends a `304 Not Modified` status code and the response will not have a body. If not, you should get a normal 200 response, provided the document still exists and no other errors occur.

#### Response Headers

Response headers are returned by the server when sending back content and include a number of different header fields, many of which are standard HTTP response header and have no significance to how Cloudant operates. The list of response headers important to Cloudant are listed below.

The Cloudant design document API and the functions when returning HTML (for example as part of a show or list) enable you to include custom HTTP headers through the `headers` field of the return object.

##### Content-Type

Specifies the MIME type of the returned data. For most request, the returned MIME type is `text/plain`. All text is encoded in Unicode (UTF-8), and this is explicitly stated in the returned `Content-type`, as `text/plain;charset=utf-8`.

##### Cache-Control

The cache control HTTP response header provides a suggestion for client caching mechanisms on how to treat the returned information. Cloudant typically returns the `must-revalidate`, which indicates that the information should be revalidated if possible. This is used to ensure that the dynamic nature of the content is correctly updated.

##### Content-Length

The length (in bytes) of the returned content.

##### Etag

The `Etag` HTTP header field is used to show the revision for a document or the response from a show function. For documents, the value is identical to the revision of the document. The value can be used with an `If-None-Match` request header to get a `304 Not Modified` response if the revision is still current.

ETags cannot currently be used with views or lists, since the ETags returned from those requests are just random numbers that change on every request.

### HTTP Status Codes

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