## Document Versioning and MVCC

Multi-version concurrency control (MVCC) is how Cloudant databases ensure that all of the nodes in a database's cluster contain only the [newest version](#documents) of a document. Since Cloudant databases are [eventually consistent](#acid), this is neccesary to prevent inconsistencies between nodes from syncronizing to outdated documents. 

### Revisions

Every document in a Cloudant database has a `_rev` field indicating its revision number. You must specify the previous `_rev` when [updating a document](#update) or else your request will fail and return a [409 error](#errors).


You can query a particular revision using its `_rev`, however, older revisions are regularly deleted by a process called [compaction](http://en.wikipedia.org/wiki/Data_compaction). [Create a new document](#create36) per revision to better implement version control.

### Distributed Databases and Conflicts

Distributed databases work without a constant connection to the main database on Cloudant, which is itself distributed, so updates based on the same previous version can still be in conflict.

To find conflicts, add the query parameter `conflicts=true` when retrieving a document. The document will contain a `_conflicts` array with all conflicting revisions.

To find conflicts for multiple documents in a database, write a view. To the right is a map function that emits all conflicting revisions for every document that has a conflict.

```
function (doc) {
  if (doc._conflicts) {
    emit(null, [doc._rev].concat(doc._conflicts));
  }
}
```

You can then regularly query this view and resolve conflicts as needed, or query the view after each replication.

### How to resolve conflicts

Once you've found a conflict, you can resolve it in 4 steps.

 * [Get](#get-conflicting-revisions) the conflicting revisions.
 * [Merge](#merge-the-changes) them in your application or ask the user what he wants to do.
 * [Upload](#upload-the-new-revision) the new revision.
 * [Delete](#delete-old-revisions) old revisions.

Let's look at an example of how this can be done. Suppose you have a database of products for an online shop. The first version of a document might look like this example on the right.

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

#### Get conflicting revisions

You get the document with `conflicts=true` like this:

`http://$USERNAME.cloudant.com/products/$_ID?conflicts=true`

And get the following response:

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

The version with the changed price has been chosen arbitrarily as the latest version of the document and the conflict is noted in the `_conflicts` array. In most cases this array has only one element, but there can be many conflicting revisions.

#### Merge the changes

To compare the revisions to see what has been changed, your application gets all of the versions from the database with URLs like this:

* `http://$USERNAME.cloudant.com/products/$_ID`
* `http://$USERNAME.cloudant.com/products/$_ID?rev=2-61ae00e029d4f5edd2981841243ded13`
* `http://$USERNAME.cloudant.com/products/$_ID?rev=1-7438df87b632b312c53a08361a7c3299`

Since these two changes are for different fields of the document, it is easy to merge them.

Other conflict resolution strategies are:

* time based: first or last edit
* reporting conflicts to users and letting them decide on the best resolution
* more sophisticated merging algorithms, e.g. 3-way merges of text fields

#### Upload the new revision

In this example, you produce the document to your right and update the database with it.

```json
{
  "_id": "74b2be56045bed0c8c9d24b939000dbe",
  "_rev": "3-daaecd7213301a1ad5493186d6916755",
  "name": "Samsung Galaxy S4",
  "description": "Latest smartphone from Samsung",
  "price": 600
}
```

#### Delete old revisions

Then to delete the old revisions, send a DELETE request to the URLs with the revisions we want to delete.

```http
DELETE http://$USERNAME.cloudant.com/products/$_ID?rev=2-61ae00e029d4f5edd2981841243ded13
```

```http
DELETE http://$USERNAME.cloudant.com/products/$_ID?rev=2-f796915a291b37254f6df8f6f3389121
```

After this, conflicts are resolved and you can verify this by getting the document again with the conflicts parameter set to true.
