# backend-test

This repository is just for testing a possible backend microservice architecture. The idea is to build a server that can listen for Restful requests via Servant, publish and listen topics in kafka, and uses PostgreSQL to store data.

### Getting started

You need to have [stack installed](https://docs.haskellstack.org/en/stable/README/)

Until I make this to run inside docker, we need to have librdkafka installed globally

```bash
$ git clone https://github.com/edenhill/librdkafka
$ cd librdkafka
$ LDFLAGS=-L/usr/local/opt/openssl/lib CPPFLAGS=-I/usr/local/opt/openssl/include ./configure
$ make && make install
```

### Develop

You can run a REPL with the environment loaded

```bash
# Copy from .env_example.sh
$ source .env.sh
$ stack repl --no-nix-pure
```

Build documentation

```bash
# Generate haddock of local project (Apps are ommited :/)
$ stack build --haddock --haddock-deps --fast --haddock-arguments "--odir=dist/docs --hyperlinked-source"
# Serve hoogle to search with the installed packages
$ stack hoogle -- server --local --port=8090
# If you install a new package and need to refresh the index use
$ stack hoogle -- generate --local
```

## Developer tools

### Auto formatter

Install ormolu in your system

```bash
# If you use the vscode extensio remember to configure the bin to the output
# of this command.
$ stack build --copy-compiler-tool ormolu
```

If you use the ormolu extension in vscode, remember to point to the bin
TODO: Add comments on how to do it manually.
TODO: Add a step that validates formmating before commiting.

### IDE

It is recommended to use [Simple GHC](https://marketplace.visualstudio.com/items?itemName=dramforever.vscode-ghc-simple)

TODO: add in the .vscode folder the autorecommend of tools

### Troubleshoot

If you See generated code from avro definitions

```bash
# TODO see how to build just one file and dump this
$ stack build --ghc-options='-ddump-splices'
```

# TODO

- Add a kafka consumer and producer
- Read the configuration from file
- Add a servant API endpoint
- Run inside docker
- Connect to a PSQL database a store stuff
