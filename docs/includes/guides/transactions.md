## Transactions in Cloudant

In a shopping app, purchases must reflect charges and a change in inventory. However, if one of those processes fails while others succeed, your information becomes inconsistent. While previous revisions of your documents might be lost to [compaction](http://en.wikipedia.org/wiki/Data_compaction), regularly holding on to older data can slow things down.

The easiest way to achieve consistency is *not* update documents at all.

In the case of the shopping app, instead insert documents like the first example on the right.

```json
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
```

`item` and `account` are IDs for other objects in your database. To calculate a running total for an account, we would use a view like the second example.

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

Calling this view with the `group=true&key={account}` options gives you a running balance for a particular account. To give refunds, insert a document with values to balance to balance out the transaction in question.

Logging events and aggregating them to determine an object's state is called [event sourcing](http://martinfowler.com/eaaDev/EventSourcing.html). It can provide SQL-like transactional atomicity even in a [NoSQL database](#json) like Cloudant.

### Event Sourcing

In event sourcing, the database's [atomic](#acid_atomic) unit is the document, which means if a document fails to write, it should never leave the database in an inconsistent state.

Documents should be understood as a sum of their interactions instead of merely their current state. In the case of the shopping app, this would be representing an account as every transaction logged within it instead of just its current balance.

### Grouping Transactions

The `_uuids` ([UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier)) endpoint can be used to maintain purchases as individual documents when they are purchased through a shopping cart in a single transaction.

By default, `https://$USERNAME.cloudant.com/_uuids` returns one ID. An array of multiple IDs can be called with `_uuids?count=$NUMBER`, so `?count=3` would return something like the array on the right.

```json
{
  "uuids": [
    "320afa89017426b994162ab004ce3383",
    "320afa89017426b994162ab004ce3b09",
    "320afa89017426b994162ab004ce4083"
  ]
}
```

These arrays can be used to generate a shared transaction `_id` which allows you to retrieve them as a group later. A view for this might look something like the example to the right.

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

Therefore a `_view/transactions?key={transaction_id}&include_docs=true` query retrieves every change associated with a transaction.

### Mapping Data into Events

The `dbcopy` map can be used to migrate data into events, and then output them to another database, in order to better accomodate event sourcing.

A document like the first example can be mapped into another database using the view, or [MapReduce index](#mapreduce), in the second example. The results will be document in the events database like the third example.

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
