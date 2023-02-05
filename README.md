# Poetry Dockerfile setup for CI/CD and production

This repository is a CI/CD template for a python project using Poetry and Docker (Python and poetry could be replaced
with any other language and package manager, as the approaches are language agnostic).

It shows an approach for building a docker image for the application and running the tests through docker compose.

The overall goal is have to **quick** and **reliable** CI/CD pipeline, that's simple to set up and maintain.

As in most applications the steps are:

- checkout the code
- setup the environment
- install the dependencies
- run tests
- build and publish

In this repository I will focus mainly on the application pipeline, but the same approach can be used for the libraries.

## Multi-stage dockerfile with docker compose

Benefits:

- Single place have a way to run the same build locally and on GH actions
- Version updates is one place
- Easy to reproduce and debug locally
- The same image is used in the CI/CD pipeline and in production

Downsides:

- Not the most straightforward way to set up if someone doesn't have experience with docker

### Caching

To keep the build time low, the dependencies are cached in the docker image, and published to github registry.

The docker image has builder stage, where the dependencies are installed, and the ci and application stages, where the dependencies are copied from the builder stage.

The main reason for that is to keep the production image size small.

### docker stages

- builder - used to install the dependencies and cache them
- ci - used to run the tests, scripts, linting and other checks 
- release - used in production - only the application / library code is copied. 

### Docker compose

To simplify the setup on the CI/CD pipeline, the docker compose is used to run the tests. This way the same setup can be checked and debugged locally as well.

## App

```sh
GITHUB_SHA=x CURRENT_BRANCH=y docker-compose -f "docker-compose.ci.yml" build ci
```