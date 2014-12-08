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

> Maven dependency details:

```
<dependency>
  <groupId>com.cloudant</groupId>
  <artifactId>cloudant-client</artifactId> 
  <version>1.0.0-beta1</version>
</dependency>
```

> Gradle dependency details:

```
dependencies {
  compile group: 'com.cloudant', name: 'cloudant-client', version:'1.0.0-beta1'
}
```

[java-cloudant](https://github.com/cloudant/java-cloudant) is the official Cloudant library for Java. You can add it as a dependency to your maven or gradle builds.

### Node.js

```
npm install cloudant
```

[nodejs-cloudant](https://github.com/cloudant/nodejs-cloudant) is the official Cloudant library for Node.js. You can install it with npm.

### Python

```
pip install cloudant
```

[Cloudant-Python](https://github.com/cloudant-labs/cloudant-python) is Cloudant's official Python library. Install it using pip.
