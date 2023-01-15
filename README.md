# Poetry Dockerfile setup for CI/CD and production

This repository is a CI/CD template for a python project using Poetry and Docker (Python and poetry could be replaced
with any other language and package manager, as the approaches are language agnostic).

It focuses on two distinct approaches how to set up the CI/CD pipeline:

- Using a multi-stage dockerfile to build the image and run tests through docker compose
- Use open docker github actions to run the tests and build the image

The overall goal is have to **quick** and **reliable** CI/CD pipeline, that's simple to set up and maintain.

As in most applications the steps are:

- checkout the code
- setup the environment
- install the dependencies
- run tests
- build and publish

In this repository I will focus mainly on the application pipeline, but the same approach can be used for the libraries.

## Approaches

### Docker build github actions

Benefits:

- Easy to set up
- Ready to use actions (poetry, python, cache). The most popular ones have a lot of options and are well maintained
- Performance through caching

Downsides:

- Hard to reproduce locally and debug
- Differs from the production environment. The actual Dockerfile might be different from the one used in the CI/CD
  pipeline
- Updating the actions might break the pipeline

### Multi-stage dockerfile with docker compose

Benefits:

- Single place have a way to run the same build locally and on GH actions
- Version updates is one place
- Easy to reproduce and debug locally
- The same image is used in the CI/CD pipeline and in production

Downsides:

- Native github actions seems to be faster (GH cache for dependencies is faster than docker cache)
- Not the most straightforward way to set up if someone doesn't have experience with docker

## App

```sh
GITHUB_SHA=x CURRENT_BRANCH=y docker-compose -f "docker-compose.ci.yml" build ci
```