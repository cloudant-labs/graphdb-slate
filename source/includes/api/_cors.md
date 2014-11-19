CORS
----

[Cross-origin resource sharing (CORS)](http://www.w3.org/TR/cors/) is a mechanism that allows resources (e.g. JSON documents in a Cloudant database) to be requested from Javascript running on a website loaded from another domain. Such "cross-domain" requests would otherwise be forbidden by web browsers, due to the same origin security policy. CORS defines a way in which the browser and the server can interact to determine whether or not to allow the request. For Cloudant, there are two use cases in which CORS might be a good solution. First, you might have a website on `https://www.example.com` and you want scripts on this website to be able to access data from `https://example.cloudant.com`. In this case, you would add `https://www.example.com` to your list of allowed origins and scripts loaded from this domain would be allowed to make AJAX requests to your Cloudant databases. You can even use HTTP auth with CORS requests, so you can grant users of your application access to their database only. Another use case is allowing third parties to be able to access your database. Say you have a database with product information and you want sales partners to be able to access this information from Jsvascript running on their own domain. You can add their domain to your list of allowed origins and scripts running on their website will be able to access your Cloudant database.

### Browser support

CORS is supported by all current versions of commonly used browsers. The main obstacle to wider adoption is Internet Explorer. Versions prior to 10 only offer partial support, versions prior to 8 offer no support at all.

### Security

If you are storing sensitive user data in databases that can be accessed via CORS, you need to take special care not to expose such data. By placing a domain in the list of allowed origins, you trust the Javascript from this domain. If the web application running on such a domain was vulnerable to a cross site scripting attack, this could expose user data from your database. Also, if you allow scripts loaded via HTTP rather than HTTPS to access data using CORS, a man in the middle attack might be used to modify such scripts. If you are dealing with sensitive information, we therefore recommend to allow CORS requests only from HTTPS origins and to make sure web applications running on allowed origin domains do not have cross site scripting vulnerabilities.

### Configuration endpoints

<table>
<colgroup>
<col width="5%" />
<col width="17%" />
<col width="76%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Method</th>
<th align="left">Path</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">GET</td>
<td align="left">/_api/v2/user/config/cors</td>
<td align="left">Returns the current CORS configuration</td>
</tr>
<tr class="even">
<td align="left">PUT</td>
<td align="left">/_api/v2/user/config/cors</td>
<td align="left">Changes the CORS configuration</td>
</tr>
</tbody>
</table>

### JSON format

-   **enable\_cors**: boolean value to turn CORS on or off.
-   **allow\_credentials**: boolean value to allow authentication credentials. If set to true, browser requests must be done using `withCredentials = true`.
-   **origins**: “origins”: An array of string containing allowed origin domains. You have to specify the full URL including the protocol. It is recommended that only the HTTPS protocol is used. Subdomains count as seperate domains, so you have to specify all subdomains used. See the example request below.

### Setting the CORS configuration

> Example request

```http
PUT /_api/v2/user/config/cors HTTP/1.1
Host: $USERNAME.cloudant.com
```

```shell
curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_api/v2/user/config/cors -X PUT
```

```json
{
    "enable_cors": true,
    "allow_credentials": true,
    "origins": [
         "https://example.com",
         "https://www.example.com"
     ]
}
```

> Response

```json
{ "ok": true }
```

`PUT`ting a json document with the above structure to `/_api/v2/user/config/cors` sets the CORS configuration. The configuration applies to all databases and all account level endpoints in your account.


### Reading the CORS configuration

> Example request

```http
GET /_api/v2/user/config/cors HTTP/1.1
Host: username.cloudant.com
```

```shell
curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_api/v2/user/config/cors
```

> Example response

```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 178
```

```json
{
    "enable_cors": true,
    "allow_credentials": true,
    "origins": [
        "https://example.com",
        "https://www.example.com"
    ]
}
```

> If there is no CORS configuration yet, an empty JSON document is returned.

```json
{}
```

`GET`ting `/_api/v2/user/config/cors` returns the CORS config in a JSON document.

