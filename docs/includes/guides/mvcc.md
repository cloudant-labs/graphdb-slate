## Document Versioning and MVCC

Multi-version concurrency control (MVCC) is how Cloudant databases ensure that all of the nodes in a database's cluster contain only the [newest version](#documents) of a document. Since Cloudant databases are [eventually consistent](#acid), this is neccesary to prevent inconsistencies between nodes from syncronizing to outdated documents. 

### Revisions

Every document in a Cloudant database has a `_rev` field indicating its revision number. You must specify the previous `_rev` when [updating a document](#update) or else your request will fail and return a [409 error](#errors).


You can query a particular revision using its `_rev`, however, older revisions are regularly deleted by a process called compaction. [Create a new document](#create28) per revision to better implement version control.

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
