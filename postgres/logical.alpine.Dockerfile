# This images turns on following replication parameters, they can be twekead at runtime
# wal_level = logical
# max_wal_senders = 10
# max_replication_slots = 10
FROM postgres:18-alpine AS build
ADD https://github.com/eulerto/wal2json/archive/refs/tags/wal2json_2_6.tar.gz /tmp/wal2json_2_6.tar.gz
RUN apk update && \
    apk add coreutils \
    gcc \
    g++ \
    libc-dev \
    linux-headers \
    clang19 \
    llvm19 \
    make \
    tar && \
    cd /tmp && \
    tar -xzf wal2json_2_6.tar.gz && \
    cd wal2json-wal2json_2_6 && \
    make clean && \
    make install && \
    rm -rf /tmp/wal2json && \
    rm -rf /var/cache/apk/*

FROM postgres:18-alpine
LABEL maintainer="Avinash Kumar avi410vikram@gmail.com"
COPY --from=build /usr/local/lib/postgresql /usr/local/lib/postgresql
COPY postgres/configs/logical.postgresql.conf /var/lib/postgresql/data/postgresql.conf

CMD ["postgres", "-c", "config_file=/var/lib/postgresql/data/postgresql.conf"]