## Account

Your account, which lives at `https://$USERNAME.cloudant.com`, is your entry point for Cloudant's API. Your Cloudant dashboard is always `https://$USERNAME.cloudant.com/dashboard.html`.

If you don't yet have an account, [sign up](https://cloudant.com/sign-up/).

### Ping

```shell
curl -u $USERNAME https://$USERNAME.cloudant.com
```

```python
import cloudant

account = cloudant.Account(USERNAME)
ping = account.get()
print ping.status_code
# 200
```

To see if your Cloudant account is accessible, make a `GET` against `https://YOUR_USERNAME.cloudant.com`.
