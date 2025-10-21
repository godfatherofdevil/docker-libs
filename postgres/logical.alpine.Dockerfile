# This images turns on following replication parameters, they can be twekead at runtime
# wal_level = logical
# max_wal_senders = 10
# max_replication_slots = 10
FROM postgres:18-alpine
LABEL maintainer="Avinash Kumar avi410vikram@gmail.com"
COPY postgres/configs/logical.postgresql.conf /var/lib/postgresql/data/postgresql.conf

CMD ["postgres", "-c", "config_file=/var/lib/postgresql/data/postgresql.conf"]