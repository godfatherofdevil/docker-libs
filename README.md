# docker-libs

Alpine-focused Dockerfiles and pre-built images for tools that are difficult to use on Alpine Linux through official channels.

The repository exists to close a recurring gap: many upstream projects either do not publish Alpine-compatible images, do not support musl-based builds well, or only document glibc-oriented installation paths. That becomes a practical problem when the rest of your stack is Alpine-based and you want to keep images small, consistent, and easy to deploy.

This repository currently covers PostgreSQL extensions and ONNX Runtime, but it is not limited to those. More Alpine-oriented images can be added as new gaps appear and when there is no solid official distribution path.

Pre-built images are published through GitHub Packages for this repository:

- https://github.com/godfatherofdevil?tab=packages&repo_name=docker-libs

## What is included

### PostgreSQL with pgvector

File: `postgres/pgvector.alpine.Dockerfile`

Builds a `postgres:18-alpine` based image and compiles the `pgvector` extension from source during a separate build stage.

What it does:

- Uses `postgres:18-alpine` as the base image.
- Builds `pgvector` from source from the `v0.8.1` tag.
- Copies the compiled extension artifacts into the final runtime image.
- Runs an init script that enables the `vector` extension automatically on first database initialization.

Related files:

- `postgres/init/init_pgvector.sql`

Sample pull:

```bash
docker pull ghcr.io/godfatherofdevil/pgvector-alpine:latest
```

Local commands:

```bash
make build_pgvector_alpine
make run_pgvector
```

The provided run target starts PostgreSQL on port `5432` with a persistent Docker volume and `POSTGRES_PASSWORD=secret`.

### PostgreSQL with logical replication and wal2json

File: `postgres/logical.alpine.Dockerfile`

Builds a `postgres:18-alpine` based image for logical replication workflows and compiles the `wal2json` output plugin from source.

What it does:

- Uses `postgres:18-alpine` as the base image.
- Builds `wal2json` from the `wal2json_2_6` release source tarball.
- Ships a PostgreSQL config with logical replication enabled.
- Starts PostgreSQL with that config file explicitly selected at container startup.

Enabled PostgreSQL settings:

- `wal_level=logical`
- `max_wal_senders=10`
- `max_replication_slots=10`

Related files:

- `postgres/configs/logical.postgresql.conf`
- `postgres/init/init_pgwal_test.sql`

Sample pull:

```bash
docker pull ghcr.io/godfatherofdevil/logical-alpine:latest
```

Local commands:

```bash
make build_logical_alpine
make run_logical
```

The provided run target starts PostgreSQL on port `5432` with a persistent Docker volume and `POSTGRES_PASSWORD=secret`.

### ONNX Runtime for Alpine

File: `onnx/onnxruntime.alpine.Dockerfile`

Builds ONNX Runtime natively against musl so the resulting shared library can run on Alpine without adding glibc compatibility layers.

What it does:

- Clones `microsoft/onnxruntime` at `v1.23.1`.
- Builds a shared ONNX Runtime library with tests and benchmarks disabled.
- Installs the runtime into `/opt/onnxruntime`.
- Produces a small Alpine runtime image with the required C++ runtime libraries.

Related files:

- `onnx/overrides/onnxruntime/core/common/semver.h`
- `onnx/overrides/onnxruntime/core/platform/posix/stacktrace.cc`

Sample pull:

```bash
docker pull ghcr.io/godfatherofdevil/onnxruntime-alpine:latest
```

Local commands:

```bash
make build_onnxruntime_alpine
make run_onnxruntime_alpine
```

The resulting container opens a shell in `/opt/onnxruntime` with `LD_LIBRARY_PATH=/opt/onnxruntime/lib`.

### ONNX Runtime with Python bindings for Alpine

File: `onnx/onnxruntime.python.Dockerfile`

Builds ONNX Runtime from source on Alpine and packages the Python bindings into a `python:3.12-alpine` runtime image.

What it does:

- Clones `microsoft/onnxruntime` at `v1.23.1`.
- Builds the shared library and Python wheel from source.
- Installs the generated wheel during the build stage.
- Copies the prepared Python site-packages into the final Alpine-based Python runtime image.
- Keeps the native ONNX Runtime libraries under `/opt/onnxruntime`.

Sample pull:

```bash
docker pull ghcr.io/godfatherofdevil/onnxruntime-python:latest
```

Local commands:

```bash
make build_onnxruntime_python
make run_onnxruntime_python
```

The resulting container starts a Python 3 interpreter with the ONNX Runtime Python package already installed.

## Build targets

The repository includes a simple `Makefile` for local image builds and demo runs:

```bash
make build_pgvector_alpine
make run_pgvector

make build_logical_alpine
make run_logical

make build_onnxruntime_alpine
make run_onnxruntime_alpine

make build_onnxruntime_python
make run_onnxruntime_python
```

The ONNX Runtime images use `docker buildx build --load` in the provided targets. The PostgreSQL images use standard `docker build`.

## Why this repository exists

If you are standardizing on Alpine Linux, official container images are often not enough:

- some projects do not publish Alpine variants at all
- some publish images that are not suitable for musl-based environments
- some extensions or bindings need to be compiled from source to work reliably on Alpine

This repository keeps those Alpine-specific build recipes in one place so they are repeatable and easy to reuse.

## Scope

The current images solve specific Alpine compatibility problems that have been painful in real projects. The repository will grow only when there is a concrete need for another image and official support remains unavailable or incomplete.
