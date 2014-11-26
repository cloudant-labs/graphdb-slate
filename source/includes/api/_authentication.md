## Authentication

Authentication means proving who you are.
This is typically done by providing your user credentials for verification.
There are two ways that clients can provide credentials (authenticate)
with Cloudant: Basic and Cookie.
Basic authentication is like showing an ID at a door for checking every time you want to enter.
Cookie authentication is like having a key to the door so that you can let yourself in whenever you want.

### Basic Authentication

```http
GET /db/document HTTP/1.1
Authentication dXNlcm5hbWU6cGFzc3dvcmQ=
```

```shell
curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com
```

```python
import cloudant

url = "https://{0}:{1}@{0}.cloudant.com".format(USERNAME, PASSWORD)
account = cloudant.Account(url)
ping = account.get()
print ping.status_code
# 200
```

```javascript
var nano = require('nano');
var account = nano("https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com");

account.request(function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

With Basic authentication, you pass along your credentials as part of every request by adding an `Authentication` header. The value is the base-64 encoding of your username, followed by `:`, followed by your password. However, most HTTP libraries do this encoding for you.

### Cookies

> Get a cookie

```http
POST /_session HTTP/1.1
Content-Length: 32
Content-Type: application/x-www-form-urlencoded
Accept: */*

name=YourUserName&password=YourPassword
```

> Reply with Set-Cookie header.

```
200 OK
Cache-Control: must-revalidate
Content-Length: 42
Content-Type: text/plain; charset=UTF-8
Date: Mon, 04 Mar 2013 14:06:11 GMT
server: CouchDB/1.0.2 (Erlang OTP/R14B)
Set-Cookie: AuthSession="a2ltc3RlYmVsOjUxMzRBQTUzOtiY2_IDUIdsTJEVNEjObAbyhrgz"; Expires=Tue, 05 Mar 2013 14:06:11 GMT; Max-Age=86400; Path=/; HttpOnly; Version=1
x-couch-request-id: a638431d

{
  "ok": true,
  "name": "kimstebel",
  "roles": []
}
```

> Once you have obtained the cookie, you can make a GET request to obtain your roles:

```http
GET /_session HTTP/1.1
Cookie: AuthSession="a2ltc3RlYmVsOjUxMzRBQTUzOtiY2_IDUIdsTJEVNEjObAbyhrgz"; Expires=Tue, 05 Mar 2013 14:06:11 GMT; Max-Age=86400; Path=/; HttpOnly; Version=1
Accept: application/json
```

```json
{
  "ok": true,
  "info": {
    "authentication_db": "_users",
    "authentication_handlers": ["cookie", "default"]
  },
  "userCtx": {
    "name": null,
    "roles": []
  }
}
```

> To log out, you have to send a DELETE request to the same URL and sumbit the Cookie in the request.

```http
DELETE /_session HTTP/1.1
Cookie: AuthSession="a2ltc3RlYmVsOjUxMzRBQTUzOtiY2_IDUIdsTJEVNEjObAbyhrgz"; Expires=Tue, 05 Mar 2013 14:06:11 GMT; Max-Age=86400; Path=/; HttpOnly; Version=1
Accept: application/json

200 OK
Cache-Control: must-revalidate
Content-Length: 12
Content-Type: application/json
Date: Mon, 04 Mar 2013 14:06:12 GMT
server: CouchDB/1.0.2 (Erlang OTP/R14B)
Set-Cookie: AuthSession=""; Expires=Fri, 02 Jan 1970 00:00:00 GMT; Max-Age=0; Path=/; HttpOnly; Version=1
x-couch-request-id: e02e0333

{
  "ok": true
}
```

```shell
# get cookie
curl https://$USERNAME.cloudant.com/_session \
     -X POST \
     -c /path/to/cookiefile
     -d "name=$USERNAME&password=$PASSWORD"

# use cookie
curl https://$USERNAME.cloudant.com/_session \
     -b /path/to/cookiefile
```

```python
import cloudant

account = cloudant.Account(USERNAME)
login = account.login(USERNAME, PASSWORD)
print login.status_code
# 200
logout = account.logout()
print logout.status_code
# 200
all_dbs = account.all_dbs()
print all_dbs.status_code
# 401
```

```javascript
var nano = require('nano');
var cloudant = nano("https://"+$USERNAME+".cloudant.com");
var cookies = {}

cloudant.auth($USERNAME, $PASSWORD, function (err, body, headers) {
  if (!err) {
    cookies[$USERNAME] = headers['set-cookie'];
    cloudant = nano({
      url: "https://"+$USERNAME+".cloudant.com",
      cookie: cookies[$USERNAME] 
    });

    // ping to ensure we're logged in
    cloudant.request({
      path: 'test_porter'
    }, function (err, body, headers) {
      if (!err) {
        console.log(body, headers);
      }
    }); 
  }
});
```

With Cookie authentication, you use your credentials to acquire a cookie which remains active for twenty-four hours. You send the cookie with all requests until it expires. Logging out causes the cookie to expire immediately.

The cookie can be obtained by performing a POST request to /_session. With the cookie set, information about the logged in user can be retrieved with a GET request. With a DELETE request you can end the session. Further details are provided below.

|Method |	Path |	Description |	Headers |	Form Parameters|
|-------|------|--------------|---------|----------------------|
|GET |	/_session |	Returns cookie based login user information |	AuthSession cookie returned by POST request |	—|
|POST |	/_session |	Do cookie based user login |	Content-Type: application/x-www-form-urlencoded |	name, password|
|DELETE |	/_session |	Logout cookie based user |	AuthSession cookie returned by POST request |	—|


