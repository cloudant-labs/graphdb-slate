## Transactions in Cloudant

Say you've got a shopping app. There are items, accounts, purchases,
etc., and at the end of the day, the books must balance. If a user
purchases something, you must appropriately charge the account, and
reflect that change in inventory. If any of those steps fails, but
others succeed, your system is left out of whack. If you were updating
documents to reflect these changes, the previous versions of those
documents might be lost, requiring you to take particular precaution in
your app layer to handle failure cases, thus bloating your code. Is
there an easier way to achieve consistency?

Yes. As Sam Bisbee put it, "Don't update documents." In the case of the
shopping app, instead insert documents like this:

    {
      "type": "purchase",
      "item": "...",
      "account": "...",
      "quantity": 2,
      "unit_price": 99.99
    }

    {
      "type": "payment",
      "account": "...",
      "value": 199.98
    }

`item` and `account`, then, are IDs for other objects in your database.
To calculate a running total for an account, we would use a view like
this:

```javascript
{
  views: {
    totals: {
      map: function(doc){
        if(doc.type === 'purchase'){
          emit(doc.account, doc.quantity * doc.unit_price);
        }else{
          if(doc.type === 'payment'){
            emit(doc.account, -doc.value);
          } 
        }
      },
      reduce: '_sum'
    }
  }
}
```

Voila! Now calling this view with the `group=true&key={account}` options
will give us a running balance for a particular account. If you need to
roll back a purchase or payment, just insert a document with values to
balance out the interaction you want to negate.

This practice of logging events, and aggregating them to determine an
object's state, is called *event sourcing*. Used well, it provides
SQL-like transactional atomicity even in a NoSQL database like Cloudant.

### Event Sourcing

SQL databases often have transactional semantics that allow you to
commit changes in an all-or-nothing fashion: if any of the changes fail,
the database rejects the whole package. Papers like
[ARIES](http://202.202.43.2/users/1008/docs/6176-1.pdf)[S](http://202.202.43.2/users/1008/docs/6176-1.pdf)
lay out how this works, and how to implement it to ensure
[ACID](http://en.wikipedia.org/wiki/ACID) transactions. Although
Cloudant lacks these semantics directly, you can use a strategy called
[Event Sourcing](http://martinfowler.com/eaaDev/EventSourcing.html) to
get dang close.

Event sourcing, in a nutshell, is the strategy we outlined above:
reflect changes through document insertions rather than updates, then
use secondary indexes to reflect overall application state.

In event sourcing, the database's atomic unit is the document. If a
document fails to write, it should never leave the database in an
inconsistent state. So, we break documents into interactions: rather
than updating an account document with its current balance, we calculate
it and other dynamic values by aggregating the interactions the account
was involved in. As much as possible, represent objects as the sum of
their interactions.

### Using \_uuids to group transactions

Say in our shopping app, you have a shopping cart where users can hold
items before purchasing, and which they ultimately purchase as a group.
How can we group these purchases, while maintaining each purchase as a
single document? Use the `_uuids` endpoint!

`https://{user}.cloudant.com/_uuids` returns an array of unique IDs
which have an approximately negligible chance of overlapping with your
document IDs. By default, it returns one ID, but you can set count in
your querystring to get more. For example, calling `_uuids?count=3`
yields this:

```json
{
  "uuids": [
    "320afa89017426b994162ab004ce3383",
    "320afa89017426b994162ab004ce3b09",
    "320afa89017426b994162ab004ce4083"
  ]
}
```

This way, when the user purchases everything in their cart, you can use
`_uuids` to generate a shared transaction\_id that allows you to
retrieve them as a group later. For that, we might use a view like this:

```javascript
{
  views: {
    transactions: {
      map: function(doc){
        if(doc.type === 'purchase'){
          emit(doc.transaction_id, null);
        }
      }
    }
  }
}
```

We can then use queries like
`_view/transactions?key={transaction_id}&include_docs=true` to retrieve
every change associated with a transaction.

### Using dbcopy to map data into events

Say your database consists of data that simply doesn't lend itself to
event sourcing. Perhaps you uploaded documents that have rows of events
in them, and you'd like to migrate your data to better accommodate an
event sourcing strategy. To address this, we can use `dbcopy` to map our
current data into events, and then output them to another database.

Say you've got documents like this:

```javascript
{
  account_id: '...',
  balance: '...',
  transaction_history: [{
    date: '...',
    item: '...',
    quantity: '...',
    unit_price: 100
  },{
    date: '...',
    transaction_id: '...',
    destination_account: '...',
    change: 50
  }]
}
```

To map that into another database as a series of transaction events, try
this:

```javascript
{
  views: {
    events: {
      map: function(doc){
        for(var i in doc.transaction_history){
          var transaction = doc.transaction_history[i];
          emit({
            from: doc.account_id,
            to: transaction.destination_account,
            transaction_id: transaction.transaction_id,
            date: transaction.date
          }, transaction.change);
        }
      },
      dbcopy: 'events'
    }
  }
}
```

This will output the results of the map function into the events
database, filling it with documents like this:

```javascript
{
  key: {
    from: '...',
    to: '...',
    transaction_id: '...',
    date: '...'
  },
  value: 100
}
```

And lo, from barren earth we have made a garden. Nifty, eh?

### Summary

Although Cloudant's eventual consistency model makes satisfying ACID's
consistency requirement difficult, you can satisfy the rest of the
requirements through how you structure your data. For event sourcing,
regard these guidelines:

-   The atomic unit is the document. The database should never find
    itself in an inconsistent state because a document failed to write.

-   Use secondary indexes, not documents, to reflect overall application
    state.

-   If you've got unruly data, use `dbcopy` to map it into a friendly
    way and output it to another database.

If you have any trouble with any of this, post your question on
[StackOverflow](http://stackoverflow.com/search?tab=votes&q=cloudant%20is%3aquestion),
hit us up on
[IRC](http://webchat.freenode.net/?channels=cloudant&uio=MTE9MTk117), or
if you'd like to speak more privately, send us a note at
<support@cloudant.com>
