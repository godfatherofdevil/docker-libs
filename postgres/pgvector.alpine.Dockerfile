FROM postgres:18-alpine AS build
ADD https://github.com/pgvector/pgvector.git#v0.8.1 /tmp/pgvector

# build the pgvector extension from source
RUN apk update && \
    apk add coreutils \
    gcc \
    g++ \
    libc-dev \
    linux-headers \
    clang19 \
    llvm19 \
    make && \
    cd /tmp/pgvector && \
    make clean && \
    make OPTFLAGS="" && \
    make install && \
    apk del coreutils make libc-dev && \
    rm -rf /tmp/pgvector && \
    rm -rf /var/cache/apk/*

FROM postgres:18-alpine
LABEL maintainer="Avinash Kumar avi410vikram@gmail.com"
# copy required files from build stage
COPY --from=build /usr/local/lib/postgresql /usr/local/lib/postgresql
COPY --from=build /usr/local/share/postgresql /usr/local/share/postgresql
COPY --from=build /usr/local/include/postgresql /usr/local/include/postgresql
COPY postgres/init/init_pgvector.sql /docker-entrypoint-initdb.d/init.sql

CMD ["postgres"]
