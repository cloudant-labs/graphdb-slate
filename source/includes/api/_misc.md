## Monitoring cluster status, and replication tasks

These endpoints provide information about the state of the cluster and let you manage replication tasks.

A list of the available methods and URL paths is as follows:

Method | Path | Description
-------|------|------------
`GET` | `/` | Get the welcome message and version information.
`GET` | `/_active_tasks` | Obtain a list of the tasks running in the server.
`GET` | `/_membership` | Obtain a list of nodes in the cluster.
`GET` | `/_all_dbs` | Get a list of all the databases.
`POST` | `/_replicate` | Set or cancel a replication task.
`GET` | `/_uuids` | Get the generated UUIDs from the servers.

### Retrieving information about the server

> Example JSON response containing server meta information:

```json
{
  "couchdb": "Welcome",
  "version": "1.0.2",
  "cloudant_build":"1138"
}
```

-  **Method**: `GET`
-  **Path**: `/`
-  **Response**: Welcome message and version

Accessing the database rather than a document within the database returns meta information about the server. The response is a JSON structure containing information about the server, including a welcome message and the version of the server. The `version` field contains the CouchDB version the server is compatible with.
The `cloudant_build` field contains the build number of Cloudant's CouchDb implementation.

### Retrieving a list of active tasks

> Example JSON response array, containing details of currently running tasks:

``` json
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
  },
  
  {
    "user": "acceptly",
    "updated_on": 1363273779,
    "type": "indexer",
    "node": "dbcore@db11.julep.cloudant.net",
    "pid": "<0.20723.4070>",
    "changes_done": 189,
    "database": "shards/00000000-3fffffff/acceptly/acceptly_my_chances_logs_live.1321035717",
    "design_document": "_design/MyChancesLogCohortReport",
    "started_on": 1363273094,
    "total_changes": 26389
  },
  
  {
    "user": "username",
    "updated_on": 1371118433,
    "type": "search_indexer",
    "total_changes": 5466,
    "node": "dbcore@db7.meritage.cloudant.net",
    "pid": "<0.29569.7037>",
    "changes_done": 4611,
    "database": "shards/40000000-7fffffff/username/database_name",
    "design_document": "_design/lucene",
    "index": "search1",
    "started_on": 1371118426
  },
  
  {
    "view": 1,
    "user": "acceptly",
    "updated_on": 1363273504,
    "type": "view_compaction",
    "total_changes": 26095,
    "node": "dbcore@db11.julep.cloudant.net",
    "pid": "<0.21218.4070>",
    "changes_done": 20000,
    "database": "shards/80000000-bfffffff/acceptly/acceptly_my_chances_logs_live.1321035717",
    "design_document": "_design/MyChancesLogCohortReport",
    "phase": "view",
    "started_on": 1363273094
  },
  
  {
    "updated_on": 1363274040,
    "node": "dbcore@db11.julep.cloudant.net",
    "pid": "<0.29256.4053>",
    "changes_done": 272195,
    "database": "shards/00000000-3fffffff/heroku/app3245179/id_f21a08b7005e_logs.1346083461",
    "started_on": 1363272496,
    "total_changes": 272195,
    "type": "database_compaction"
  }
]
```

-   **Method**: `GET`
-   **Path**: `/_active_tasks`
-   **Response**: List of running tasks, including the task type, name, status and process ID
-   **Roles permitted**: `_admin`

You can obtain a list of active tasks by using the `/_active_tasks` URL. The result is a JSON array of the currently running tasks, with each task being described with a single object.

The returned structure includes the following fields for each task:

-   **pid**: Erlang Process ID
-   **type**: Operation Type
-   **updated\_on**: Time when the last update was made to this task record. Updates are made by the job as progress occurs. The value is in Unix time UTC.
-   **started\_on**: Time when the task was started. The value is in Unix time UTC.
-   **total\_changes**: Total number of documents to be processed by the task. The exact meaning depends on the type of the task.
-   **database**: The database and shard on which the operation occurs.

In the `type` field, possible values include:

-   `database_compaction`
-   `view_compaction`
-   `replication`
-   `indexer`
-   `search_indexer`

The meaning of other fields in the JSON response depends on the type of the task.

#### Specific response fields for compaction tasks

-   **total\_changes**: Number of documents in the database.
-   **changes\_done**: Number of documents compacted.
-   **phase**: Reports the stage of compaction.

In the `phase` field, the value indicates the stage that compaction has reached:

1. `ids`: Document compaction is in progress.
2. `views`: View compaction is in progress.

#### Specific response fields for replication tasks

-   **replication\_id**: Unique identifier of the replication that can be used to cancel the task.
-   **user**: User who started the replication.
-   **changes\_pending**: Number of documents needing to be changed in the target database.
-   **revisions\_checked**: Number of document revisions for which it was checked whether they are already in the target database.
-   **continuous**: Whether the replication is continuous.
-   **docs\_read**: Documents read from the source database.

#### Specific response fields for indexing tasks

-   **design\_document**: The design document containing the view or index function or functions.
-   **total\_changes**: Total number of unindexed changes from when the MVCC snapshot was opened.
-   **changes\_done**: Number of document revisions processed by this task. A document can have one or more revisions.

### Obtaining a list of nodes in a cluster

> Example request to list nodes in the cluster:

```
GET /_membership HTTP/1.1
Accept: application/json
```

> Example JSON response listing the nodes in the cluster:

```json
{
  "all_nodes": ["dbcore@db1.testy004.cloudant.net", "dbcore@db2.testy004.cloudant.net", "dbcore@db3.testy004.cloudant.net"],
  "cluster_nodes": ["dbcore@db1.testy004.cloudant.net", "dbcore@db2.testy004.cloudant.net", "dbcore@db3.testy004.cloudant.net"]
}
```
-   **Method**: `GET`
-   **Path**: `/_membership`
-   **Response**: JSON document listing cluster nodes and all nodes
-   **Roles permitted**: \_admin

#### Response structure

-   `cluster_nodes`: Array of node names (strings) of the active nodes in the cluster
-   `all_nodes`: Array of nodes names (strings) of all nodes in the cluster

### Replicating a database

-   **Method**: `POST`
-   **Path**: `/_replicate`
-   **Request**: Replication specification
-   **Response**: TBD
-   **Roles permitted**: \_admin

#### Return Codes

Code | Description
-----|------------
`200` | Replication request successfully completed.
`202` | Continuous replication request has been accepted.
`404` | Either the source or target database was not found.
`500` | JSON specification was invalid.

Use this call to request, configure, or stop, a replication operation.

The specification of the replication request is controlled through the JSON content of the request. The JSON should be an object with fields defining the source, target and other options. The fields of the JSON request are as follows:

-   **cancel**: (Optional) Cancels the replication.
-   **continuous**: (Optional) Configure the replication to be continuous.
-   **create\_target**: (Optional) Creates the target database.
-   **doc\_ids**: (Optional) Array of document IDs to be synchronized.
-   **proxy**: (Optional) Address of a proxy server through which replication should occur.
-   **source**: Source database URL, including user name and password.
-   **target**: Target database URL, including user name and password.

<aside class="notice">Replication takes place in one direction only.
To keep two databases synchronized with each other, you must replicate in both directions.
This means that you must replicate from `databasea` to `databaseb`, and separately from `databaseb` to `databasea`.</aside>

#### Replication Operation

> Example request to replicate between a database on the source server `example.com`, and a target database on Cloudant:

```
POST /_replicate
Content-Type: application/json
Accept: application/json

{
   "source" : "http://user:pass@example.com/db",
   "target" : "http://user:pass@user.cloudant.com/db",
}
```

> Example error reponse if one of the requested databases for a replication does not exist:

```json
{
   "error" : "db_not_found"
   "reason" : "could not open http://username.cloudant.com/ol1ka/",
}
```

The aim of replication is that at the end of the process, all active documents on the source database are also in the destination or 'target' database, and that all documents deleted from the source databases are also deleted from the destination database (if they existed there).

Replication has two forms: push or pull replication:

-   *Push replication* is where the `source` is a local database, and `destination` is a remote database.

-   *Pull replication* is where the `source` is the remote database instance, and the `destination` is the local database.

Pull replication is helpful if your source database has a permanent IP address, and your destination database is local and has a dynamically assigned IP address, for example, obtained through DHCP.
Pull replication is especially appropriate if you are replicating to a mobile or other device from a central server.

In all cases, the requested databases in the `source` and `target` specification must exist. If they do not, an error is returned within the JSON object.

#### Creating a target database during replication

> Example request to create a target database and replicate onto it:

```
POST http://username.cloudant.com/_replicate
Content-Type: application/json
Accept: application/json

{
   "create_target" : true
   "source" : "http://user:pass@example.com/db",
   "target" : "http://user:pass@user.cloudant.com/db",
}
```

If your user credentials allow it, you can create the target database during replication by adding the `create_target` field to the request object.

The `create_target` field is not destructive. If the database already exists, the replication proceeds as normal.

### Single Replication

> Example request for a single synchronization between the source database `recipes` and the target database `recipes2`.

```
POST /_replicate
Content-Type: application/json
Accept: application/json

{
   "source" : "http://user:pass@user.cloudant.com/recipes",
   "target" : "http://user:pass@user.cloudant.com/recipes2",
}
```

> Example response following a request for a single replication:

``` json
{
   "ok" : true,
   "history" : [
      {
         "docs_read" : 1000,
         "session_id" : "52c2370f5027043d286daca4de247db0",
         "recorded_seq" : 1000,
         "end_last_seq" : 1000,
         "doc_write_failures" : 0,
         "start_time" : "Thu, 28 Oct 2010 10:24:13 GMT",
         "start_last_seq" : 0,
         "end_time" : "Thu, 28 Oct 2010 10:24:14 GMT",
         "missing_checked" : 0,
         "docs_written" : 1000,
         "missing_found" : 1000
      }
   ],
   "session_id" : "52c2370f5027043d286daca4de247db0",
   "source_last_seq" : 1000
}
```

Replication of a database means that the the two databases - the 'source' and the 'target' - are synchronized. By default, the replication process occurs one time, and synchronizes the two databases together.

The response to a request for a single replication is a JSON structure containing the success or failure status of the synchronization process. The response also contains statistics about the process.

The structure of the response includes details about the replication status:

-  **history [array]**: Replication History
  -  **doc\_write\_failures**: Number of document write failures
  -  **docs\_read**: Number of documents read
  -  **docs\_written**: Number of documents written to target
  -  **end\_last\_seq**: Last sequence number in changes stream
  -  **end\_time**: Date/Time replication operation completed
  -  **missing\_checked**: Number of missing documents checked
  -  **missing\_found**: Number of missing documents found
  -  **recorded\_seq**: Last recorded sequence number
  -  **session\_id**: Session ID for this replication operation
  -  **start\_last\_seq**: First sequence number in changes stream
  -  **start\_time**: Date/Time replication operation started
-  **ok**: Replication status
-  **session\_id**: Unique session ID
-  **source\_last\_seq**: Last sequence number read from source database

### Continuous Replication

> Example request for a continuous replication between two databases.

```
POST /_replicate
Content-Type: application/json
Accept: application/json

{
   "continuous" : true
   "source" : "http://user:pass@example.com/db",
   "target" : "http://user:pass@user.cloudant.com/db",
}
```

By default, the synchronization of a database during replication happens only once, at the time the replicate request is made. To ensure that replication from the source database to the target database takes place continually, set the `continuous` field of the JSON object within the request to `true`.

With continuous replication changes in the source database are replicated to the target database in perpetuity until you specifically request that replication ceases.

Changes will be replicated between the two databases as long as a network connection is available between the two instances.

<aside class="warning">Replication takes place in one direction only.
To keep two databases synchronized with each other continuously, you must also replicate in both directions, continuously.
This means that you must enable continuous replication from `databasea` to `databaseb`, and additionally from `databaseb` to `databasea`.</aside>

### Canceling Continuous Replication

> Example replication request to create the target database if it does not exist, and to replicate continuously:

```
POST /_replicate
Content-Type: application/json
Accept: application/json

{
   "source" : "http://user:pass@example.com/db",
   "target" : "http://user:pass@user.cloudant.com/db",
   "create_target" : true,
   "continuous" : true
}
```

Example request to cancel the replication, providing matching fields to the original request:

```
POST /_replicate
Content-Type: application/json
Accept: application/json

{
    "cancel" : true,
    "continuous" : true
    "create_target" : true,
    "source" : "http://user:pass@example.com/db",
    "target" : "http://user:pass@user.cloudant.com/db",
}
```

Cancel continuous replication by including the `cancel` field in the JSON request object, and setting the value to `true`.

<aside class="warning">For the cancelation request to succeed, the structure of the request must be identical to the original request. In particular, if you requested continuous replication, the cancellation request must also contain the `continuous` field.</aside>

Requesting cancellation of a replication that does not exist results in a 404 error.

### Retrieving UUIDs

> Example request for a single UUID:

```
GET /_uuids
```

> Example response to a request for a single UUID:

``` json
{
   "uuids" : [
      "7e4b5a14b22ec1cf8e58b9cdd0000da3"
   ]
}
```

> Example request for five UUIDs:

```
GET /_uuids?count=5
```

> Example response to a request for five UUIDs:

``` json
{
   "uuids" : [
      "c9df0cdf4442f993fc5570225b405a80",
      "c9df0cdf4442f993fc5570225b405bd2",
      "c9df0cdf4442f993fc5570225b405e42",
      "c9df0cdf4442f993fc5570225b4061a0",
      "c9df0cdf4442f993fc5570225b406a20"
   ]
}
```

-   **Method**: `GET`
-   **Path**: `/_uuids`
-   **Response**: JSON document containing a list of UUIDs

Argument | Description | Optional | Type
---------|-------------|----------|-----
`count` | Number of UUIDs to return | yes | numeric

This command requests one or more Universally Unique Identifiers (UUIDs). The response is a JSON object providing a list of UUIDs.

Use the `count` argument to specify the number of UUIDs to be returned.
