# Ruby + Node

A starting point for containers using both Ruby and Node. Comes with `bundler`, `npm` and `yarn` pre-installed.

Dockerfiles live in folders following this convention: `[RUBY_MAJOR]-[NODE_MAJOR]/alpine/Dockerfile`. Tags are created with both the major and minor versions. Only the latest major version Dockerfile is kept in the repository.

Currently images are only created for Alpine.

* Ruby is built from [source](https://cache.ruby-lang.org/pub/ruby/).
* Node binaries(and their checksums) from the [Unofficial Builds Project](https://unofficial-builds.nodejs.org/download/release/).

## Building an image

In the folder of a given combination of Ruby and Node

```sh
docker build -t madebytight/rude:[RUBY_MAJOR]-[NODE_MAJOR]-alpine -t madebytight/rude:[RUBY_MINOR]-[NODE_MINOR]-alpine .
```
