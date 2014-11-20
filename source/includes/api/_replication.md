<h2 id="ReplicationAPI">Replication</h2>

Cloudant replication is the process that synchronizes ('syncs') the state of two databases.
Any change which has occured in the source database is reproduced in the target database.
You can create replications between any number of databases, whether continuous or not.
Depending on your application requirements, you use replication to share and aggregate state and content.

Replications can be represented as [documents](#documents) in the `_replicator` database.
This means that working with replications is the same as working with documents.
Replications can also be started by `POST`ing documents to the `/_replicate` endpoint. Here is the format of the document:

Field Name | Required | Description
-----------|----------|-------------
source | yes | Identifies the database to copy revisions from. Can be a database URL, or an object whose url property contains the full URL of the database.
target | yes | Identifies the database to copy revisions to. Same format and interpretation as source.
continuous | no | Continuously syncs state from the source to the target, only stopping when deleted.
create_target | no | A value of true tells the replicator to create the target database if it doesn't exist.
doc_ids | no | Array of document IDs; if given, only these documents will be replicated.
filter | no | Name of a [filter function](#filter-functions) that can choose which documents get replicated.
proxy | no | Proxy server URL.
query_params | no | Object containing properties that are passed to the filter function.
use_checkpoints | no | Whether to create checkpoints. Checkpoints greatly reduce the time and resources needed for repeated replications. Setting this to false removes the requirement for write access to the source database. Defaults to true.

### Replicator database

#### Creating a replication

```shell
curl -X PUT https://$USERNAME:$PASSWORD@USERNAME.cloudant.com/_replicator/replication-doc -H 'Content-Type: application/json' -d @replication-document.json
#assuming replication-document.json is a json file with the following content:
```

```http
PUT /_replicator/replication-doc HTTP/1.1
Content-Type: application/json
```

```json
{
  "source": "https://$USERNAME1:$PASSWORD1@$USERNAME1.cloudant.com/$DATABASE1",
  "target": "https://$USERNAME2:$PASSWORD2@$USERNAME2.cloudant.com/$DATABASE2",
  "create_target": true,
  "continuous": true
}
```

To start a replication, [add a document](#documentCreate) to the `_replicator` database.

#### Monitoring a replication

```shell
curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_active_tasks
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");

account.request({
  path: '_active_tasks'
}, function (err, body, headers) {
  if (!err) {
    console.log(body.filter(function (task) {
      return (task.type === 'replication');
    })); 
  }
});
```

```json
[
  {
    "user": null,
    "updated_on": 1363274088,
    "type": "replication",
    "target": "https://repl:*****@tsm.cloudant.com/user-3dglstqg8aq0uunzimv4uiimy/",
    "docs_read": 0,
    "doc_write_failures": 0,
    "doc_id": "tsm-admin__to__user-3dglstqg8aq0uunzimv4uiimy",
    "continuous": true,
    "checkpointed_source_seq": "403-g1AAAADfeJzLYWBgYMlgTmGQS0lKzi9KdUhJMjTRyyrNSS3QS87JL01JzCvRy0styQGqY0pkSLL___9_VmIymg5TXDqSHIBkUj1YUxyaJkNcmvJYgCRDA5AC6tuflZhGrPsgGg9ANAJtzMkCAPFSStc",
    "changes_pending": 134,
    "pid": "<0.1781.4101>",
    "node": "dbcore@db11.julep.cloudant.net",
    "docs_written": 0,
    "missing_revisions_found": 0,
    "replication_id": "d0cdbfee50a80fd43e83a9f62ea650ad+continuous",
    "revisions_checked": 0,
    "source": "https://repl:*****@tsm.cloudant.com/tsm-admin/",
    "source_seq": "537-g1AAAADfeJzLYWBgYMlgTmGQS0lKzi9KdUhJMjTUyyrNSS3QS87JL01JzCvRy0styQGqY0pkSLL___9_VmI9mg4jXDqSHIBkUj1WTTityWMBkgwNQAqob39WYhextkE0HoBoBNo4MQsAFuVLVQ",
    "started_on": 1363274083
  }
]
```

To monitor replicators currently in process, make a GET request to `https://$USERNAME.cloudant.com/_actice_tasks`. This will return any active tasks including but not limited to replications. To filter for replications, just look for documents with `"type": "replication"`.

Field | Description | Type
------|-------------|------
replication_id | Unique identifier of the replication that can be used to cancel the task | string
user | User who started the replication | string or null
changes_pending | Number of documents needing to be changed in the target database | integer
revisions_checked | Number of document revisions for which it was checked whether they are already in the target database integer
continuous | Whether the replication is continuous | boolean
docs_read | Documents read from the source database | integer
started_on | The replication's start date in seconds since the UNIX epoch | integer
updated_on | When the replication was last updated, in seconds since the UNIX epoch | integer
source | An obfuscated URL indicating the database from which the task is replicating | string
target | An obfuscated URL indicating the database to which the task is replicating | string

#### Delete

```http
DELETE /_replicator/replication-doc?rev=1-... HTTP/1.1
```

```shell
curl -X DELETE https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_replicator/replication-doc?rev=1-...
```

To cancel a replication, simply [delete its document](#delete33) from the `_replicator` database.

### Replication using the /\_replicate endpoint

Replication can be triggered by sending a POST request to the `/_replicate` URL.

```shell
curl -H 'Content-Type: application/json' -X POST "https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_replicate" -d @replication-doc.json
#with the file replication-doc.json containing the following:
```

```http
POST /_replicate HTTP/1.1
Content-Type: application/json
```

```json
{
  "source": "http://$USERNAME:$PASSWORD@username.cloudant.com/example-database",
  "target": "http://$USERNAME2:$PASSWORD2@example.org/example-target-database"
}
```

The target database has to exist and is not implicitly created. Add `"create_target":true` to the JSON document to create the target database prior to replication. 

#### Canceling replication

```shell
curl -H 'Content-Type: application/json' -X POST 'https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_replicate HTTP/1.1' -d @replication-doc.json
#the file replication-doc.json has the following content:
```

```http
POST /_replicate HTTP/1.1
Content-Type: application/json
```

```json
{
  "source": "https://username:password@username.cloudant.com/example-database",
  "target": "https://username:password@example.org/example-database",
  "cancel": true
}
```

A replication triggered by POSTing to `/_replicate/` can be canceled by POSTing the exact same JSON object but with the additional `cancel` property set to `true`.

Notice: the request which initiated the replication will fail with error 500 (shutdown).

The replication ID can be obtained from the original replication request (if it's a continuous replication) or from `/_active_tasks`.

#### Example

```shell
$ curl -H 'Content-Type: application/json' -X POST 'http://username.cloudant.com/_replicate' -d @replication-doc.json
#the file replication-doc.json has the following content:
```

```http
POST /_replicate HTTP/1.1
Content-Type: application/json
```

```json
{
  "source": "https://username:password@example.com/foo", 
  "target": "https://username:password@username.cloudant.com/bar", 
  "create_target": true, 
  "continuous": true
}
```

```json
{
  "ok": true,
  "_local_id": "0a81b645497e6270611ec3419767a584+continuous+create_target"
}
```

First we start the replication.

###### dummy

```shell
curl -H 'Content-Type: application/json' -X POST http://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_replicate -d @replication-doc.json
# where the file replication-doc.json has the following content:
```

```http
POST /_replicate HTTP/1.1
Content-Type: application/json
```

```json
{
  "replication_id": "0a81b645497e6270611ec3419767a584+continuous+create_target",
  "cancel": true
}
```

```json
{
  "ok": true,
  "_local_id": "0a81b645497e6270611ec3419767a584+continuous+create_target"
}
```

We use this id to cancel the replication.

The `"ok": true` reply indicates that the replication was successfully canceled.

### Continuous replication

```shell
curl -H 'Content-Type: application/json' -X POST http://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/_replicate -d @replication-doc.json
# where the file replication-doc.json has the following content:
```

```http
POST /_replicate HTTP/1.1
Content-Type: application/json
```

```json
{
  "source": "http://username:password@example.com/foo", 
  "target": "http://username:password@username.cloudant.com/bar", 
  "continuous": true
}
```

To make replication continuous, add a `"continuous":true` parameter to the JSON. This way, the replication process will not stop when it has processed all current updates and will wait for further updates to the source database and apply them to the target.

### Filtered Replication

```
function(doc, req) {
  return !!(doc.type && doc.type == "foo");
}
```

Sometimes you don't want to transfer all documents from source to target. You can include one or more filter functions in a design document on the source and then tell the replicator to use them.

A filter function takes two arguments (the document to be replicated and the the replication request) and returns true or false. If the result is true, the document is replicated.

###### h6

```json
{
  "_id": "_design/myddoc",
  "filters": {
    "myfilter": "function goes here"
  }
}
```

Filters live under the top-level "filters" key;

###### h6

```json
{
  "source": "http://username:password@example.org/example-database",
  "target": "http://username:password@username.cloudant.com/example-database",
  "filter": "myddoc/myfilter"
}
```

Invoke them as follows:

###### h6

```json
{
  "source": "http://username:password@example.org/example-database",
  "target": "http://username:password@username.cloudant.com/example-database",
  "filter": "myddoc/myfilter",
  "query_params": {
    "key": "value"
  }
}
```

You can even pass arguments to them.

### Named Document Replication

```json
{
  "source": "http://username:password@example.org/example-database",
  "target": "http://username:password@127.0.0.1:5984/example-database",
  "doc_ids": ["foo", "bar", "baz"]
}
```

Sometimes you only want to replicate some documents. For this simple case you do not need to write a filter function. Simply add the list of keys in the doc\_ids field.


### Replicating through a proxy

```json
{
  "source": "http://username:password@username.cloudant.com/example-database",
  "target": "http://username:password@example.org/example-database",
  "proxy": "http://my-proxy.com:8888"
}
```

Pass a "proxy" argument in the replication data to have replication go through an HTTP proxy:

### Authentication

```json
{
  "source": "https://username:password@example.com/db", 
  "target": "https://username:password@username.cloudant.com/db"
}
```

The source and the target database may require authentication, and if checkpoints are used (on by default), even the source will require write access. The easiest way to authenticate is to put a username and password into the URL; the replicator will use these for HTTP Basic auth:

### Performance related options

These options can be set per replication by including them in the replication document.

-   `worker_processes` - The number of processes the replicator uses (per replication) to transfer documents from the source to the target database. Higher values can imply better throughput (due to more parallelism of network and disk IO) at the expense of more memory and eventually CPU. Default value is 4.
-   `worker_batch_size` - Workers process batches with the size defined by this parameter (the size corresponds to number of ''\_changes'' feed rows). Larger batch sizes can offer better performance, while lower values imply that checkpointing is done more frequently. Default value is 500.
-   `http_connections` - The maximum number of HTTP connections per replication. For push replications, the effective number of HTTP connections used is min(worker\_processes + 1, http\_connections). For pull replications, the effective number of connections used corresponds to this parameter's value. Default value is 20.
-   `connection_timeout` - The maximum period of inactivity for a connection in milliseconds. If a connection is idle for this period of time, its current request will be retried. Default value is 30000 milliseconds (30 seconds).
-   `retries_per_request` - The maximum number of retries per request. Before a retry, the replicator will wait for a short period of time before repeating the request. This period of time doubles between each consecutive retry attempt. This period of time never goes beyond 5 minutes and its minimum value (before the first retry is attempted) is 0.25 seconds. The default value of this parameter is 10 attempts.
-   `socket_options` - A list of options to pass to the connection sockets. The available options can be found in the [documentation for the Erlang function setopts/2 of the inet module](http://www.erlang.org/doc/man/inet.html#setopts-2). Default value is `[{keepalive, true}, {nodelay, false}]`.

#### Example

```json
{
  "source": "https://username:password@example.com/example-database",
  "target": "https://username:password@example.org/example-database",
  "connection_timeout": 60000,
  "retries_per_request": 20,
  "http_connections": 30
}
```

### Advanced content

Clients implementing the [replication protocol](http://dataprotocols.org/couchdb-replication/) should check out the [Advanced Methods](#advanced14).
