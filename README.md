# Graph Data Store documentation

The documentation site, built using [slate](https://github.com/cloudant-labs/slate).

## Install

If you want to work on the docs locally, install [Ruby](https://www.ruby-lang.org/en/) and [bundler](http://bundler.io/), then do this:

    git clone git@github.com:cloudant-labs/slate.git
    cd slate
    bundle install
    bundle exec middleman server

Alternatively, you can use Vagrant and Virtualbox to set up a development environment. Once Vagrant and Virtualbox have been installed, run

    git clone git@github.com:cloudant-labs/slate.git
    cd slate
    sudo vagrant up

In both cases, your docs site will be reachable at <http://localhost:4567/>.

Note that the search bar will not work locally because it uses Cloudant's search handler.

## Deploy to bluemix

Merge your changes into the production brnach and then follow  instructions here: https://github.com/KimStebel/graphdb-slate-bluemix

## Contribute

For more details on what we expect from contributions, see [CONTRIBUTING.MD](https://github.com/cloudant-labs/slate/blob/master/CONTRIBUTING.md).

## License

[MIT](http://opensource.org/licenses/MIT).

## This is really the end.
