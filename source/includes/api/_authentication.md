# Authentication

Authentication just means verifying user credentials. There are two ways that clients can authenticate with Cloudant: Basic and Cookie. The difference is essentially like showing an ID at a door versus borrowing a key to the door.

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

With Basic authentication, you pass along your credentials as part of every request.

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

With Cookie authentication, you use your credentials to acquire a cookie which remains active for twenty four hours. You send the cookie with all requests until it expires.

Logging out causes the cookie to expire immediately.
