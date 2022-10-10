# Project bench-ms-forward
Temporary development repository for the ms-forward microservice.

## Description

The purpose of this project is to provide a development environment for the new ms-forward microservice component. It contains all necessary sources, makefiles to build binaries and containers and docker-compose files for testing the application. 

### Demo application

The fastest way to get the demo running:

- Enter the `src` directory.
- Run `source setup.sh`.
- Run `make`.
- Enter the `src/docker/old` directory and run `docker-compose up`
- Access `http://127.0.0.1:30080` with your browser

This 'weatherstation' consists of three components:

- The frontend, written in angular and served by an nginx container.
- A microservice 'ms-measure'. This provides the temperature shown in the frontend.
- A microservice 'ms-random'. This provides a random number to `ms-measure`.

You can access the microservices directly:

- `curl http://127.0.0.1:30081/measure` shows the reply of `ms-measure`.
- `curl http://127.0.0.1:30081/random` shows the reply of `ms-random`.

### The new component `ms-forward`

It's sometimes desirable to have a more complex application than just two microservices. Instead of adding artificial complexity, a simple microservice will be introduced, that forwards all requests it gets to an other microservice and returns the reply to the original requestor. So instead of this request chain:

    Browser -> ms-measure -> ms-random

we'll get this:

    Browser -> ms-measure -> ms-forward -> ms-random

This scenario is available via docker compose in the `src/docker/new-1` directory.
In fact, to make things more interesting, `ms-forward` shall be able to forward one incoming request to multiple microservices (but return only the reply of the first ms):

    Browser -> ms-measure -> ms-forward -> ms-random-1
                                        -> ms-random-2

This scenario is available via docker compose in the `src/docker/new-2` directory.

# Basic setup

Working environment:

- Linux working environment (i.e. WSL2). Distribution is not important, as long as it can use docker.
- bash shell, make, docker (for WSL2: docker for desktop)
- Optional go 1.18 (or newer)
- Optional npm & angular

First step: in the root directory execute `source setup.sh`. this will set some environment variables.

# Building the binaries:

## Local builds

All build-actions are done via makefiles. Enter one of the subdirectories of src/go or src/angular and enter `make`. This will start a local build. Technically speaking, local builds are not necessary, you can use the docker build commands (see below). This will directly build the docker images and no local deployment of go or npm is necessary.

## Docker builds

To build an individual component: Enter its subdirectory in src/go or src/angular and run `make docker`.
To build all components, enter the src directory and run `make`.

## Clean up

To remove docker images and running containers, run `make clean` or `make distclean` in the src directory. All containers and images with a certain set of labels (see below) will be stopped and removed.

# Docker images and containers

The images build are using both a specific naming scheme and a set of labels to better distinguish them from other containers. All containers started by the docker-compose files use the same labels and values.

## Image labels

 - Label `CUSTOMER` should have value `com.gft.bench` for all images.
 - Label `PROJECT` should have value `com.gft.bench.ms-forward` for all images.
 - Label `MODULE` has one of the values 'frontend', 'application', 'backend'.
 - Label `COMPONENT` should be the name of the subdirectory in src/go or src/angular.
 
 The labels `CUSTOMER`and `PROJECT` are identical for all images and containers.
 
 ## Image names
 
 The image names uses the values of the above labels to better identify the images: `<PROJECT>.<MODULE>.<COMPONENT>` example: `com.gft.bench.ms-forward.backend.ms-random`
 
 All images are tagged as `base`.
 
 ## Docker compose
 
 In src/docker you'll find several subdirectories with docker-compose files. These represent the state of the demo application:
 
  - `old` is the current state of the application. It can be run at any time since it's not using the new component `ms-forward`.
  - `new-1` and `new-2` are examples with the new component `ms-forward`. They show example uses of the new component.

  # Requirements

  The new MS shall be build on the same framework as `ms-measure` and `ms-random` (`github.com/com-gft-tsbo-source/go-common`). It shall support the same common options as both `ms-measure` and `ms-random` from the common framework (i.e. port number, version number, ...). Additionally, it shall accept a new parameter `--forward-to` that can be passed multiple times. This parameter describes the way incoming requests are forwarded:

 - For every incoming request to `ms-forward`, each `--forward-to` parameter will result in a forward to the MS as described in the argument of the parameter.
 - A reply to the original request will only be made, after all forwarded requests have returned or timed-out.
 - If all forwarded requests returned a successful HTTP code, the reply of the forward of the first `--forward-to` parameter on the CLI will be returned.
 - If one or more forwarded request result in an error (either HTTP or other like timeout), this will be returned to the orignal requestor. For multiple, choose one.
 - All replies will be logged.
  
 The argument accepted by the `--forward-to` describes where the incoming request is forwarded. The format is this:

     <match pattern>:<url description>

 - `<match pattern>` is a go regular expression. `:` symbols in the expression must be quoted like this `\:`
 - `<match pattern>` matches after the host/port part of the URL, starting with the first `/`.
 - `<match pattern>` is anchored a the beginning of the URL (as if it contained a `^` at the beginning).
 - `<match pattern>` is anchored to the end of the URL (as if it contained a `$` at the end).
 - If `<match pattern>` doesn't match, the request will be ignored. This will be logged and for the purpose of error checking of the replies (see above), this is ignored too.
 - `<url description>` is a normal URL. This URL may reference capture groups of `<match pattern>`. These references need to be replaced by their values.

Example:

    --forward-to '/my/(.*)/url:http://example.com:553/url/$1/transformed'

 - `<match pattern>` is `/my/(.*)/url`. This contains a single capture group (the `(.*)` part).
 - `<url description>` is `http://example.com:553/url/$1/transformed`. This references the capture group (the `$1` part.)

 Mappings for this example:
 
 - `/my/SOMETHING/url`  -> http://example.com:553/url/SOMETHING/transformed
 - `/my//url`  -> http://example.com:553/url//transformed
 - `/my/SOMETHING/url/more/stuff` -> ignored, because the trailing `/more/stuff` is not matched (pattern is anchored with `$`)
 - `/some/other/URL` -> ignored
