# Authentication

Authentication just means verifying the authority of the user to interact with your account. There are two ways that clients can authenticate with Cloudant, refered to as Basic and Cookie.

## Basic Authentication

```shell
curl -X HEAD -u $USERNAME https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com
```

```python
import cloudant

url = "https://{0}:{1}@{0}.cloudant.com".format(USERNAME, PASSWORD)
account = cloudant.Account(url)
ping = account.get()
print ping.status_code
# 200
```

With Basic authentication, you pass along your credentials as part of every request, like showing a picture ID every time you pass security in a building.

## Cookies

```shell
TODO
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
ping = account.ping()
print ping.status_code
# 401
```

With Cookie authentication, you use your credentials to acquire a cookie which remains active for twenty four hours. You send the cookie with all requests until it expires. This is more like borrowing a key.

Logging out causes the cookie to expire immediately.
