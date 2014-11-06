## Authentication

Authentication means proving who you are.
This is typically done by providing your user credentials for verification.
There are two ways that clients can provide credentials (authenticate)
with Cloudant: Basic and Cookie.
Basic authentication is like showing an ID at a door for checking every time you want to enter.
Cookie authentication is like having a key to the door so that you can let yourself in whenever you want.

### Basic Authentication

```shell
curl -u $USERNAME https://$USERNAME.cloudant.com
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

With Basic authentication, you pass along your credentials as part of every request.

### Cookies

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

With Cookie authentication, you use your credentials to acquire a cookie which remains active for twenty four hours. You send the cookie with all requests until it expires.

Logging out causes the cookie to expire immediately.
