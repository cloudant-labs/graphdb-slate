# docs.cloudant.com

[![Build Status](https://travis-ci.org/cloudant-labs/slate.png?branch=master)](https://travis-ci.org/cloudant-labs/slate)

The Cloudant documentation, built using [slate](https://github.com/tripit/slate). Check it out [here](https://garbados.cloudant.com/api-ref/_design/couchapp/_rewrite).

## Install

If you want to work on the docs locally, do this:

    git clone git@github.com:cloudant-labs/slate.git
    cd slate
    bundle install
    bundle exec middleman server

Now, your docs are live at <http://localhost:4567/>.

## Contribute

The Cloudant documentation is updated whenever the master branch of this repository sees a new commit, thanks to Travis and CouchApp. So, to contribute changes to the docs, just make a pull request! You can find all the copy [docs directory](https://github.com/cloudant-labs/slate/tree/master/docs), in the [intro](https://github.com/cloudant-labs/slate/blob/master/docs/index.md) or in the [includes directory](https://github.com/cloudant-labs/slate/tree/master/docs/includes). 

For more details on what we expect from contributions, see [CONTRIBUTING.MD](https://github.com/cloudant-labs/slate/blob/master/CONTRIBUTING.md).

Happy hacking!

## License

[MIT](http://opensource.org/licenses/MIT), yo.
