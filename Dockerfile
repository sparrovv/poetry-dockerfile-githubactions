ARG PYTHON_VERSION=3.10-slim-bullseye
ARG POETRY_VERSION=1.2.2

FROM python:${PYTHON_VERSION} as python

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/venv" \
    APP_PATH="/app" \
    VENV_PATH="/venv/.venv" \
    POETRY_VERSION=${POETRY_VERSION}

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Install apt packages
RUN apt-get update && apt-get install --no-install-recommends -y \
  libpq-dev

FROM python as builder

# Install packates requried for building python dependencies
RUN apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python -

# Copy Python requirements to cache them
# and install only runtime deps using poetry
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./

RUN /opt/poetry/bin/poetry install --only=main

FROM builder as builder-dev

# Install dev dependencies
RUN /opt/poetry/bin/poetry install --only=dev

FROM python as base

RUN addgroup --system app \
    && adduser --system --ingroup app app

COPY --chown=app:app . $APP_PATH

WORKDIR $APP_PATH
USER app

RUN chmod +x entrypoint
RUN mkdir -p static

FROM base as ci

COPY --from=builder-dev --chown=app:app $PYSETUP_PATH $PYSETUP_PATH

CMD ["/bin/sh"]

FROM base as release

COPY --from=builder --chown=app:app $PYSETUP_PATH $PYSETUP_PATH
# REVISION is a GIT_SHA_COMMIT that is passed in from the build command, mainly used to check what version of the image is running
ARG REVISION
ENV REVISION=${REVISION}

ENTRYPOINT ["/app/entrypoint"]
CMD ["/app/start"]
