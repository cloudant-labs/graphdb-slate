# Account

Your account, which lives at `https://YOUR_USERNAME.cloudant.com`, is your entry point for Cloudant's API.

## Ping

To see if your Cloudant account is accessible, make a `HEAD` against `https://YOUR_USERNAME.cloudant.com`.

```shell
curl -X HEAD -u $USERNAME https://$USERNAME.cloudant.com
```

```python
import cloudant

account = cloudant.Account(USERNAME)
ping = account.get()
print ping.status_code
# 200
```
