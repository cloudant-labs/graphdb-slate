# Account

Your account, which lives at `https://$USERNAME.cloudant.com`, is your entry point for Cloudant's API.

Your dashboard is always `https://$USERNAME.cloudant.com/dashboard.html` unless you want to use the old interface, which is `https://cloudant.com/dashboard/#!/`.

## Ping

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

To see if your Cloudant account is accessible, make a `HEAD` against `https://YOUR_USERNAME.cloudant.com`.
