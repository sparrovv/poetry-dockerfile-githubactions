# Poetry Dockerfile setup for cicd and production

## The goal

- Create a Dockerfile that can be used for both cicd pipeline and production
- Use poetry to install dependencies
- Use docker-compose for cicd and local development
- Quick builds with GH actions

## How to use

```sh
GITHUB_SHA=x CURRENT_BRANCH=y docker-compose -f "docker-compose.ci.yml" build ci


```