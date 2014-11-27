## Supported client libraries
<div id="supported"></div>
### Mobile

The Cloudant Sync library is used to store, index and query local JSON data on a mobile device.
It is also used to synchronise data between many devices.
Synchronisation is controlled by your application.
The library also lets you manage and resolve conflicts easily,
both in the local device or the remote database.

Two versions are available:

- <a href="https://github.com/cloudant/sync-android" target="_blank">Android / JavaSE</a>
- <a href="https://github.com/cloudant/CDTDatastore" target="_blank">iOS</a>

### Java

```
<dependency>
  <groupId>com.cloudant</groupId>
  <artifactId>cloudant-client</artifactId> 
  <version>1.0.0-beta1</version>
</dependency>
```

[java-cloudant](https://github.com/cloudant/java-cloudant) is the official Cloudant library for Java. You can add it as a dependency to your maven build.

### JavaScript

```
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/pouchdb/2.2.0/pouchdb.min.js"></script>
```

[PouchDB](http://pouchdb.com/) is a JavaScript database that can sync with Cloudant, meaning you can make your apps offline-ready just by using PouchDB. For more info, see [our blog post](https://cloudant.com/blog/pouchdb) on PouchDB.
Install it by including the PouchDB script in your app's HTML.

<aside class="notice">PouchDB is also available for Node.js: `npm install pouchdb`</aside>

### Node.js

```
npm install nano
```

[nodejs-cloudant](https://github.com/cloudant/nodejs-cloudant) is the official Cloudant library for Node.js. You can install it with npm.

### Python

```
pip install cloudant
```

[Cloudant-Python](https://github.com/cloudant-labs/cloudant-python) is Cloudant's official Python library. Install it using pip.
