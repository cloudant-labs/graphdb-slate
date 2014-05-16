## Authorization

### Roles

Cloudant has three roles:

Role | Description
----------|------------
`_reader` | Gives the user permission to read documents from the database.
`_writer` | Gives the user permission to create and modify documents in the database.
`_admin` | Gives the user all permissions, including setting permissions.

The credentials you use to log in to the dashboard automatically have `_admin` permissions to all databases you create. Everyone else, from users you share databases with to API keys you create, must be given a permission level explicitly.

### Managing Permissions

```shell
curl -X POST https://cloudant.com/api/set_permissions
  -H "Content-Type: application/x-www-form-urlencoded"
  -d "username=aUserNameOrApiKey&database=accountName/db&roles=_reader&roles=_writer"
  -u $USERNAME
```

```python
TODO
```

To modify a user's permissions, use `https://cloudant.com/api/set_permissions`.

<aside>Unlike most Cloudant endpoints, `/api/set_permissions` accepts form-encoded data rather than a JSON object in the request body.</aside>

### Creating API Keys

```shell
curl -X POST https://cloudant.com/api/generate_api_key
  -u $USERNAME
```

```python
TODO
```

> Response body:

```
{
  "password": "generatedPassword",
   "ok": true,
   "key": "generatedKey"
}
```

To generate an API key, use `https://cloudant.com/api/generate_api_key`. The created API key has no permissions to anything by default, and must be given permissions explicitly.

### CORS

TODO

![Under Construction](http://www.omgwiki.org/model-interchange/lib/exe/fetch.php?cache=cache&media=under-construction.gif)
