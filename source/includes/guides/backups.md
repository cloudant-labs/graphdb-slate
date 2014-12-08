## Back up your data

There are two kinds of people, those who've had a hard drive failure and
those who haven't had one yet. Luckily, Cloudant already takes care of
such failures by replicating all data across three nodes. So why would
you need a backup? Because there is more than one way to lose or be
unable to access data: If a data center gets hit by a tsunami, having
three nodes in that data center won't help much. Also, if a faulty
application deletes or overwrites data in the database, no amount of
duplication will prevent that. For the first scenario, you need a
cluster that spans multiple geographic locations, which we offer to
customers on our dedicated pricing plan, or you can replicate your data
to a cluster (dedicated or multi-tenant) in a different geographic
location. The second scenario is what this guide is about. In the case
of a faulty application, you need a backup that preserves the state of
the database at certain points in time.

### How to back up

Unfortunately, there is no obvious, out-of-the-box solution to this
problem. One way to go about it is to replicate the database to a dated
backup database. This certainly works and is easy to do, but if the
database is big and you need backups for multiple points in time (e.g. 7
daily backups and 4 weekly ones), you will end up with a lot of disk
usage, because you will be storing a complete copy in each new backup
database. The solution to this problem is to do incremental backups,
storing only the documents that have changed since the last backup.
After an initial full backup you start the replication process to
another database with a `since_seq` parameter, telling it where the last
replication left off.

1.  You find the ID of the checkpoint document for the last replication.
    It is stored in the `_replication_id` field of the replication
    document in the `_replicator` database.

2.  You open the checkpoint document at
    `/<database>/_local/<_replication_id>`, where `<_replication_id>` is
    the ID you found in the previous step and `<database>` is the name
    of the source or the target database. The document usually exists on
    both databases, but might only exist on one.

3.  You look for the `recorded_seq` field of the first element of the
    `history` array.

4.  You start a replication to a new database and set the `since_seq`
    field in the replication document to the value of the `recorded_seq`
    field from the previous step.

### How to restore

To restore a database from backup, you replicate each incremental backup
to a new database starting with the latest increment. You don't have to
do it in this order, but replicating from the latest incremental backup
first will be faster, because updated documents will only have to be
written to the target once.

### An example

```shell
# save base URL and the content type in shell variables
$ url='https://<username>:<password>@<username>.cloudant.com'
$ ct='Content-Type: application-json'
```

Let's say you have one database to back up, and you want to create a
full backup on Monday and an incremental one on Tuesday. You can use
curl and [jq](http://http://stedolan.github.io/jq/) to do this, but of
course any other http client will work.

<div> </div>

###### backup example create dbs

```shell
$ curl -X PUT "${url}/original"
$ curl -X PUT "${url}/backup-monday"
$ curl -X PUT "${url}/backup-tuesday"
```

```http
PUT /original HTTP/1.1
```

```http
PUT /backup-monday HTTP/1.1
```

```http
PUT /backup-tuesday HTTP/1.1
```

You create three databases, one original and two for backups.

<div> </div>

###### backup example create _replicator db

```shell
$ curl -X PUT "${url}/_replicator"
```

```http
PUT /_replicator HTTP/1.1
```

You create the \_replicator database, if it does not exist yet.

<div> </div>

###### backup example monday

```http
PUT /_replicator/backup-monday HTTP/1.1
Content-Type: application/json
```

```shell
$ curl -X PUT "${url}/_replicator/backup-monday" -H "$ct" -d @backup-monday.json
# where backup-monday.json has the following contents:
```

```json
{
  "_id": "backup-monday",
  "source": "${url}/original",
  "target": "${url}/backup-monday"
}
```

On Monday, you backup your data for the first time, so you replicate
everything from `original` to `backup-monday`.

<div> </div>

###### backup example tuesday

```http
GET /_replicator/backup-monday HTTP/1.1
```

```shell
$ replication_id=$(curl "${url}/_replicator/backup-monday" | jq -r '._replication_id')
```

On Tuesday, things get more complicated. You first need to get the ID of
the checkpoint document. It is stored in the `_replication_id` field of the replication document in the `_replicator` database.

<div> </div>

###### backup example recorded_seq

```http
GET /original/_local/${replication_id} HTTP/1.1
```

```shell
$ recorded_seq=$(curl "${url}/original/_local/${repl_id}" | jq -r '.history[0].recorded_seq')
```

Once you have that, you use it to get the `recorded_seq` value from the first element of the `history` array of the `/_local/${replication_id}` document in the `original` database.

<div> </div>

###### backup example incremental backup tuesday

```http
PUT /_replicator/backup-tuesday HTTP/1.1
Content-Type: application/json
```

```shell
$ curl -X PUT "${url}/_replicator/backup-tuesday" -H "${ct}" -d @backup-tuesday.json
# where backup-tuesday.json contains the following:
```

```json
{
  "_id": "backup-tuesday",
  "source": "${url}/original",
  "target": "${url}/backup-tuesday",
  "since_seq": "${recorded_seq}"
}
```

With the `recorded_seq` you can start the incremental backup for Tuesday.

<div> </div>

###### backup example restore monday

```http
PUT /_replicator/restore-monday HTTP/1.1
Content-Type: application/json
```

```shell
$ curl -X PUT "${url}/_replicator/restore-monday" -H "$ct" -d @restore-monday.json
# where restore-monday.json contains the following:
```

```json
{
  "_id": "restore-monday",
  "source": "${url}/backup-monday",
  "target": "${url}/restore",
  "create-target": true  
}
```

To restore from the backup, you replicate the initial full backup and
any number of incremental backups to a new database.

If you want to restore monday's state, just replicate from the
backup-monday database.

<div> </div>

###### backup example restore tuesday

```http
PUT /_replicator/restore-tuesday HTTP/1.1
Content-Type: application/json
```

```shell
$ curl -X PUT "${url}/_replicator/restore-tuesday" -H "$ct" -d @restore-tuesday.json
# where restore-tuesday.json contains the following json document:
```

```json
{
  "_id": "restore-tuesday",
  "source": "${url}/backup-tuesday",
  "target": "${url}/restore",
  "create-target": true  
}
```

```http
PUT /_replicator/restore-monday HTTP/1.1
Content-Type: application/json
```

```shell
$ curl -X PUT "${url}/_replicator/restore-monday" -H "$ct" -d @restore-monday.json
# where restore-monday.json contains the following json document:
```

```json
{
  "_id": "restore-monday",
  "source": "${url}/backup-monday",
  "target": "${url}/restore"
}
```


If you want to restore tuesday's state, first replicate from
`backup-tuesday` and then from `backup-monday`. Using this order,
documents that were updated on tuesday will only have to be written to
the target database once.

<div> </div>

### Additional hints and suggestions

While the above outlines the basic procedure, each application will have
its own requirements and thus its own strategy for backups. Here are a
few things you might want to keep in mind.

#### When to start backups

Replication jobs can significantly increase the load on a cluster. If
you are backup up several databases, you might want to start replication
jobs at different times or at times when the cluster is usually less
busy.

#### IO Priority

```json
{
  "source": {
    "url": "https://user:pass@example.com/db",
    "headers": {
      "x-cloudant-io-priority": "low"
    }
  },
  "target": {
    "url": "https://user:pass@example.net/db",
    "headers": {
      "x-cloudant-io-priority": "low"
    }
  }
}
```

It is also possible to change the priority of backup jobs by setting the
x-cloudant-io-priority field in the headers object of the target and/or
the source objects of the replication document to "low". For example:

<div> </div>

#### Design documents

If you back up design documents, indexes will be created on the backup
destination. This slows down the backup process and unnecessarily takes
up disk space. So if you don't need indexes on the backup system, use a
filter function in all replications that filters out design documents.
This can also be a good place to filter out other documents that aren't
needed anymore.

#### Backing up many databases

If your application uses one database per user or allows each user to
create several databases, backup jobs will need to be created for each
new database. Make sure that the replication jobs don't all start at the
same time.

## Need help?

Replication and backups can be a tricky topic, so if you're having any trouble, have a look at the <a href="http://docs.cloudant.com/guides/repl-index.html">replication guide</a>, talk to us on IRC (#cloudant on freenode), or email <a href="mailto:support@cloudant.com">support</a>.

