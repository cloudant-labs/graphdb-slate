## Third party client libraries
<div id="thirdparty"></div>

<aside class="warning">Third party client libraries are not maintained or supported by Cloudant.</aside>

### C# / .NET

```
/// open up the Package manager console, and invoke:
install-package mycouch.cloudant
```

[MyCouch](https://github.com/danielwertheim/mycouch) is an asynchronous CouchDB and Cloudant client for .Net.

<table>
<tr>
<th>Libraries and Frameworks</th>
<th>Examples and Tutorials</th>
</tr>
<tr>
<td>[MyCouch](https://github.com/danielwertheim/mycouch)
[LoveSeat](https://github.com/soitgoes/LoveSeat)
[Divan](https://github.com/foretagsplatsen/Divan)
[Relax](https://github.com/arobson/Relax)
[Hammock](http://code.google.com/p/relax-net/)
[EasyCouchDB](https://github.com/hhariri/EasyCouchDB)
[WDK.API.CouchDB](http://code.google.com/p/skitsanoswdk/source/browse/#svn%2Ftrunk%2FWDK10%2FWDK.API.CouchDb) from [Kanapes IDE](http://kanapeside.com/).
</td>
<td>
<ul><li>[CRUD](https://github.com/cloudant/haengematte/tree/master/c%23)</li></ul>
</td>
</tr>
</table>

### PHP

```
// download sag from http://www.saggingcouch.com/download.php
require_once('./src/Sag.php');
```

[Sag](http://www.saggingcouch.com/) is PHP's CouchDB and Cloudant client. [Sag.js](https://github.com/sbisbee/sag-js) is Sag's JavaScript counterpart.

### JavaScript

> To obtain PouchDB, and for setup details, refer to [http://pouchdb.com/](http://pouchdb.com/).

[PouchDB](http://pouchdb.com/) is a JavaScript database that can sync with Cloudant, meaning you can make your apps offline-ready just by using PouchDB. For more info, see [our blog post](https://cloudant.com/blog/pouchdb) on PouchDB.

<aside class="notice">PouchDB is also available for Node.js: `npm install pouchdb`</aside>

<aside class="notice">PouchDB can also be installed with Bower: `bower install pouchdb`</aside>

### Ruby

```
gem install couchrest
```

[CouchRest](https://github.com/couchrest/couchrest) is a CouchDB and Cloudant client with extensions for working with Rails using [CouchRest Model](https://github.com/couchrest/couchrest_model).

