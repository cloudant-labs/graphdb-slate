## Advanced replication

This section contains details about more advanced replication concepts and tasks.

You might also find it helpful to review details of the underlying [replication protocol](http://dataprotocols.org/couchdb-replication/), as well as reviewing the [Advanced Methods](#advanced) material.

### Authentication

> Example of specifying username and password values for accessing source and target databases during replication:

```json
{
  "source": "https://username:password@example.com/db", 
  "target": "https://username:password@username.cloudant.com/db"
}
```

In any production application, security of the source and target databases is essential.
In order for replication to proceed, authentication is necessary to access the databases.
In addition, checkpoints for replication are [enabled by default](#checkpoints), which means that replicating the source database requires write access.

To enable authentication during replication, include a username and password in the database URL.

### The *user\_ctx* property and delegations

> Example delegated replication document:

```json
{
  "_id": "my_rep",
  "source":  "https://username:password@myserver.com:5984/foo",
  "target":  "https://username:password@username.cloudant.com/bar",
  "continuous":  true,
  "user_ctx": {
    "name": "joe",
    "roles": ["erlanger", "researcher"]
  }
}
```

Replication documents can have a custom `user_ctx` property. This property defines the user context under which a replication runs. For the old way of triggering replications (POSTing to `/_replicate/`), this property was not needed (it didn't exist in fact) -this is because at the moment of triggering the replication it has information about the authenticated user. With the replicator database, since it's a regular database, the information about the authenticated user is only present at the moment the replication document is written to the database - the replicator database implementation is like a `_changes` feed consumer (with `?include_docs=true`) that reacts to what was written to the replicator database - in fact this feature could be implemented with an external script/program. This implementation detail implies that for non admin users, a *user\_ctx* property, containing the user's name and a subset of his/her roles, must be defined in the replication document. This is ensured by the document update validation function present in the default design document of the replicator database. This validation function also ensure that a non admin user can set a user name property in the `user_ctx` property that doesn't match his/her own name (same principle applies for the roles).

For admins, the `user_ctx` property is optional, and if it's missing it defaults to a user context with name *null* and an empty list of roles - this means design documents will not be written to local targets. If writing design documents to local targets is desired, then a user context with the roles *\_admin* must be set explicitly.

Also, for admins the `user_ctx` property can be used to trigger a replication on behalf of another user. This is the user context that will be passed to local target database document validation functions.

<aside class="notify">The `user_ctx` property only has an effect for local endpoints.</aside>

As stated before, for admins the `user_ctx` property is optional, while for regular (non admin) users it's mandatory. When the roles property of `user_ctx` is missing, it defaults to the empty list *[ ]*.

### Performance related options

> Example of including performance options in a replication document:

```json
{
  "source": "https://username:password@example.com/example-database",
  "target": "https://username:password@example.org/example-database",
  "connection_timeout": 60000,
  "retries_per_request": 20,
  "http_connections": 30
}
```

These options can be set for a replication by including them in the replication document.

-   `worker_processes` - The number of processes the replicator uses (per replication) to transfer documents from the source to the target database. Higher values can imply better throughput (due to more parallelism of network and disk IO) at the expense of more memory and eventually CPU. Default value is 4.
-   `worker_batch_size` - Workers process batches with the size defined by this parameter (the size corresponds to number of ''\_changes'' feed rows). Larger batch sizes can offer better performance, while lower values imply that checkpointing is done more frequently. Default value is 500.
-   `http_connections` - The maximum number of HTTP connections per replication. For push replications, the effective number of HTTP connections used is min(worker\_processes + 1, http\_connections). For pull replications, the effective number of connections used corresponds to this parameter's value. Default value is 20.
-   `connection_timeout` - The maximum period of inactivity for a connection in milliseconds. If a connection is idle for this period of time, its current request will be retried. Default value is 30000 milliseconds (30 seconds).
-   `retries_per_request` - The maximum number of retries per request. Before a retry, the replicator will wait for a short period of time before repeating the request. This period of time doubles between each consecutive retry attempt. This period of time never goes beyond 5 minutes and its minimum value (before the first retry is attempted) is 0.25 seconds. The default value of this parameter is 10 attempts.
-   `socket_options` - A list of options to pass to the connection sockets. The available options can be found in the [documentation for the Erlang function setopts/2 of the inet module](http://www.erlang.org/doc/man/inet.html#setopts-2). Default value is `[{keepalive, true}, {nodelay, false}]`.

