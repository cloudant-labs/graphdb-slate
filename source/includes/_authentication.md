# Authentication

Clients can authenticate with Cloudant one of two ways: Basic or Cookie.

## Basic Authentication

With Basic authentication, you pass along your credentials as part of every request.

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

## Cookies

With Cookie authentication, you use your credentials to acquire a cookie, which you send as part of future requests. This cookie expires automatically after 24 hours.

```python
import cloudant

account = cloudant.Account(USERNAME)
login = account.login(USERNAME, PASSWORD)
print login.status_code
# 200
```

Logging out causes the cookie to expire immediately.

```python

import cloudant

account = cloudant.Account(USERNAME)
account.login(USERNAME, PASSWORD).raise_for_status()
logout = account.logout()
print logout.status_code
# 200
```