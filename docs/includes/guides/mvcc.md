## Document Versioning and MVCC

Concurrent updates are a tricky subject in any kind of database. Let's have a look at how  versioning works in a Cloudant database and how you can use it to 
resolve conflicts between concurrent updates to the same document. 

### Revisions

In a Cloudant database, every document has a revision. The revision is stored in the _rev field of the document. As a developer, you should treat it as an opaque string used internally by the database and not rely on it as a counter. When you retrieve a document from the database, you can either retrieve the latest revision or you can ask for a past revision by specifying the rev query parameter. However, past revisions will only be kept in the database for a short time or if the revisions are in conflict. Otherwise, old revisions will be deleted regularly by a process called compaction. Cloudant's revisions are thus not a good fit for implementing a version control system. For this purpose, we recommend creating a new document per revision. When you update a document, you have to specify the previous revision, and if the update is successful, the _rev field will be updated automatically. However, if the revision you specified in your update request does not match the latest revision in the database, your request will fail with HTTP status 409 (conflict). This technique is called multi-version concurrency control (MVCC); it prevents concurrent updates from accidentally overwriting or reversing each other's changes, works well with disconnected clients and does not require write locks. That said, as any mechanism for dealing with concurrency, it does have some tricky parts.

### Distributed databases and conflicts

Given our story so far, it seems impossible that we could have a conflict, because any update request has to reference the latest version of the document. So how would we get a conflict? How would a document get two different updates based on the same previous version? What we haven't taken into account is that Cloudant is not one monolithic database but rather a distributed system of databases that needn't always be in sync with each other. 
This is especially true if you are developing mobile or web applications that have to work without a constant connection to the main database on Cloudant. When a document on such a disconnected database is updated while the same document on Cloudant is also updated, this will lead to a conflict when the remote database is replicated to Cloudant.
While replication from local, disconnected databases is a common source of conflicts, it is not the only one. Cloudant's own infrastructure is a distributed system and updating your Cloudant database concurrently (for example from multiple web servers) can - very rarely - also lead to conflicts. In short, no matter what kind of application you have and how it works, conflicts can always happen.

### How to find conflicts

To find out whether a document is in a conflict state, you can add the query parameter conflicts=true when you retrieve the document. The returned document will then contain a _conflicts array with all conflicting revisions.
To find conflicts for multiple documents in a database, the best approach is to write a view. Here is a map function that emits all conflicting revisions for every document that has a conflict:

```json
function(doc) {
  if (doc._conflicts) {
    emit(null, [doc._rev].concat(doc._conflicts));
  }
}
```

You can then regularly query this view and resolve conflicts as needed or query the view after each replication.

### How to resolve conflicts

Once you've found a conflict, you can resolve it in 4 steps.

 * Get the conflicting revisions.
 * Merge them in your application or ask the user what he wants to do.
 * Upload the new revision.
 * Delete old revisions.

Let's look at an example of how this can be done. Suppose we have a database of products for an online shop. The first version of a document might look like this:

```json
{
  "_id": "74b2be56045bed0c8c9d24b939000dbe",
  "_rev": "1-7438df87b632b312c53a08361a7c3299",
  "name": "Samsung Galaxy S4",
  "description": "",
  "price": 650
}
```

As the document doesn't have a description yet, someone might add one.

```json
{
  "_id": "74b2be56045bed0c8c9d24b939000dbe",
  "_rev": "2-61ae00e029d4f5edd2981841243ded13",
  "name": "Samsung Galaxy S4",
  "description": "Latest smartphone from Samsung",
  "price": 650
}
```

At the same time, someone else - working with a replicated database - reduces the price.

```json
{
  "_id": "74b2be56045bed0c8c9d24b939000dbe",
  "_rev": "2-f796915a291b37254f6df8f6f3389121",
  "name": "Samsung Galaxy S4",
  "description": "",
  "price": 600
}
```

Then the two databases are replicated, leading to a conflict.

### 1. Getting conflicting revisions

We get the document with conflicts=true like this...

http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe?conflicts=true

...and get the following response:

```json
{
  "_id":"74b2be56045bed0c8c9d24b939000dbe",
  "_rev":"2-f796915a291b37254f6df8f6f3389121",
  "name":"Samsung Galaxy S4",
  "description":"",
  "price":600,
  "_conflicts":["2-61ae00e029d4f5edd2981841243ded13"]
}
```

The version with the changed price has been chosen arbitrarily as the latest version of the document and the conflict is noted in the _conflicts array. In most cases this array has only one element, but there can be many conflicting revisions.

### 2. Merge the changes

Now your applications needs to compare the revisions to see what has been changed. To do that, it gets all the version from the database with the following URLs:

* `http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe`
* `http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe?rev=2-61ae00e029d4f5edd2981841243ded13`
* `http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe?rev=1-7438df87b632b312c53a08361a7c3299`

Since the two changes are for different fields of the document, it is easy to merge them automatically.

Depending on your application and the nature of the changes, other conflict resolution strategies might be useful. Some common strategies are:

* time based: first or last edit
* reporting conflicts to users and letting them decide on the best resolution
* more sophisticated merging algorithms, e.g. 3-way merges of text fields

### 3. Upload the new revision

We produce the following document and update the database with it.

```json
{
  "_id": "74b2be56045bed0c8c9d24b939000dbe",
  "_rev": "3-daaecd7213301a1ad5493186d6916755",
  "name": "Samsung Galaxy S4",
  "description": "Latest smartphone from Samsung",
  "price": 600
}
```

### 4. Delete old revisions

To delete the old revisions, we send a DELETE request to the URLs with the revisions we want to delete.

```http
DELETE http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe?rev=2-61ae00e029d4f5edd2981841243ded13
```

```http
DELETE http://username.cloudant.com/products/74b2be56045bed0c8c9d24b939000dbe?rev=2-f796915a291b37254f6df8f6f3389121
```

After that, the document is not in conflict any more and you can verify that by getting the document again with the conflicts parameter set to true.
