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

Libraries and Frameworks | Examples and Tutorials
-------------------------|-----------------------
[java-cloudant](https://github.com/cloudant/java-cloudant) | [CRUD](https://github.com/cloudant/haengematte/tree/master/java) with HTTP and JSON libraries.
[ektorp](http://code.google.com/p/ektorp/) | [CRUD](https://github.com/cloudant/haengematte/tree/master/java/CrudWithEktorp) with ektorp library.
[jcouchdb](http://code.google.com/p/jcouchdb/) | [Building apps using Java with Cloudant on IBM Bluemix](https://cloudant.com/blog/building-apps-using-java-with-cloudant-on-ibm-bluemix/)
[jrelax](https://github.com/isterin/jrelax) | [Build a game app with Liberty, Cloudant, and Single Sign On](http://www.ibm.com/developerworks/cloud/library/cl-multiservicegame-app/index.html?ca=drs-) Bluemix example.
[LightCouch](http://www.lightcouch.org/) | [Building a Java EE app on IBM Bluemix Using Watson and Cloudant](https://developer.ibm.com/bluemix/2014/10/17/building-java-ee-app-ibm-bluemix-using-watson-cloudant/) Bluemix example along with [YouTube video](https://www.youtube.com/watch?feature=youtu.be&v=9AFMY6m0LIU&app=desktop).
[Java Cloudant Web Starter](https://ace.ng.bluemix.net/#/store/cloudOEPaneId=store&appTemplateGuid=CloudantJavaBPTemplate&fromCatalog=true) boilerplate for Bluemix |

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
