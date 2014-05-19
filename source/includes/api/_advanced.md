## Advanced

These endpoints provide information about the state of the cluster, details about revision history, and other miscellaneous tasks.

### GET /_db_updates

```shell
curl https://$USERNAME.cloudant.com/_db_updates \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  path: '_db_updates'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
  "results": [{
    "dbname": "$DATABASE_NAME",
    "type": "created",
    "account": "$USERNAME",
    "seq": "673-g1AAAAJAeJyN0Et..."
  }],
  "last_seq": "673-g1AAAAJAeJyN0Et..."
}
```

<aside>This feature is only available to dedicated customers.</aside>

Obtains a list of changes to databases, like a global [changes feed](#list-changes). Changes can be either updates to the database, creation, or deletion of a database. Like the changes feed, the feed is not guaranteed to return changes in the correct order and might contain changes more than once. Polling modes for this method works just like polling modes for [the changes feed](#list-changes).


Argument | Description | Optional | Type | Default | Supported Values
---------|-------------|----------|------|---------|-----------------
feed | Type of feed | yes | string | normal | `continuous`: Continuous (non-polling) mode, `longpoll`: Long polling mode, `normal`: default polling mode
heartbeat | Time in milliseconds after which an empty line is sent during longpoll or continuous if there have been no changes | yes | numeric | 60000 | 
limit | Maximum number of results to return | yes | numeric | none |  
since | Start the results from changes immediately after the specified sequence number. If since is 0 (the default), the request will return all changes since the feature was activated. | yes | string | 0 | 
timeout | Number of milliseconds to wait for data in a `longpoll` or `continuous` feed before terminating the response. If both `heartbeat` and `timeout` are suppled, `heartbeat` supersedes `timeout`. | yes | numeric |  | 
descending | Whether results should be returned in descending order, i.e. the latest event first. By default, the oldest event is returned first. | yes | boolean | false | 

### GET /$DB/_shards

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_shards \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  database: $DATABASE,
  path: '_shards'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
  "shards": {
    "e0000000-ffffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "c0000000-dfffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "a0000000-bfffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "80000000-9fffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "60000000-7fffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "40000000-5fffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "20000000-3fffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ],
    "00000000-1fffffff": [
      "dbcore@db1.testy004.cloudant.net",
      "dbcore@db2.testy004.cloudant.net",
      "dbcore@db3.testy004.cloudant.net"
    ]
  }
}
```

Returns informations about the shards in the cluster, specifically what nodes contain what hash ranges.

The response's `shards` field contains an object whose keys are the hash value range constituting each shard, while each value is the array of nodes containing that a copy of that shard.

### POST /$DB/_missing_revs

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_missing_revs \
     -X POST \
     -u "$USERNAME:$PASSWORD" \
     -H "Content-Type: application/json" \
     -d "$JSON"
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  database: $DATABASE,
  path: '_missing_revs',
  method: 'POST',
  body: $JSON
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example request:

```json
{
  "$DOCUMENT_ID": [
    "$REV_1",
    "$REV_2"
  ]
}
```

> Example response:

```json
{
  "missed_revs":{
    "$DOCUMENT_ID": [
      "$REV_1"
    ]
  }
}
```

Given a list of document revisions, returns the document revisions that do not exist in the database.

### POST /$DB/_revs_diff

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_revs_diff \
     -X POST \
     -u $USERNAME \
     -d $JSON
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  database: $DATABASE,
  path: '_revs_diff',
  method: 'POST',
  body: $JSON
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example request:

```json
{
  "190f721ca3411be7aa9477db5f948bbb": [
    "3-bb72a7682290f94a985f7afac8b27137",
    "4-10265e5a26d807a3cfa459cf1a82ef2e",
    "5-067a00dff5e02add41819138abb3284d"
  ]
}
```

> Example response:

```json
{
  "190f721ca3411be7aa9477db5f948bbb": {
    "missing": [
      "3-bb72a7682290f94a985f7afac8b27137",
      "5-067a00dff5e02add41819138abb3284d"
    ],
    "possible_ancestors": [
      "4-10265e5a26d807a3cfa459cf1a82ef2e"
    ]
  }
}
```

Given a set of document/revision IDs, returns the subset of those that do not correspond to revisions stored in the database.

### GET /$DB/_revs_limit

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  path: '_revs_limit'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/_revs_limit \
     -X GET \
     -u "$USERNAME:$PASSWORD"
```

> Example response:

```
1000
```

Gets the number of past revisions of a document that Cloudant stores information on.

<aside>Although the documents associated with past revisions are automatically removed, "tombstones" remain with the `_rev` value for that revision. If a document has more revisions than the value of `_revs_limit`, Cloudant will delete the tombstones of the oldest revisions.</aside>

### PUT /$DB/_revs_limit

```shell
curl https://$USERNAME.cloudant.com/_revs_limit \
     -u $USERNAME \
     -X PUT \
     -d 1000
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  path: '_revs_limit',
  body: '1000',
  method: 'PUT'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example request:

```
1000
```

> Example response:

```json
{
  "ok": true
}
```

Sets the maximum number of past revisions that Cloudant stores information on.

<aside>Although the documents associated with past revisions are automatically removed, "tombstones" remain with the `_rev` value for that revision. If a document has more revisions than the value of `_revs_limit`, Cloudant will delete the tombstones of the oldest revisions.</aside>

### GET /_membership

```shell
curl https://$USERNAME.cloudant.com/_membership \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  path: '_membership'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
  "cluster_nodes": [
    "dbcore@db1.testy004.cloudant.net",
    "dbcore@db2.testy004.cloudant.net",
    "dbcore@db3.testy004.cloudant.net"
  ],
  "all_nodes": [
    "dbcore@db1.testy004.cloudant.net",
    "dbcore@db2.testy004.cloudant.net",
    "dbcore@db3.testy004.cloudant.net"
  ]
}
```

Returns the names of nodes in the cluster. Currently active clusters are indicated in the `cluster_nodes` field, while `all_nodes` lists all nodes active or not.

### GET /_uuids

```shell
curl https://$USERNAME.cloudant.com/_uuids \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano('https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com');

account.request({
  path: '_uuids'
}, function (err, body) {
  if (!err) {
    console.log(body);
  }
});
```

> Example response:

```json
{
   "uuids" : [
      "7e4b5a14b22ec1cf8e58b9cdd0000da3"
   ]
}
```

Requests one or more Universally Unique Identifiers (UUIDs). The response is a JSON object providing a list of UUIDs. Use the `count` query argument to specify the number of UUIDs to be returned.
