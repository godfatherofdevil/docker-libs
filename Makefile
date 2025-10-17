.PHONY: build_pgvector_alpine
build_pgvector_alpine:
	docker build . -t pgvector-alpine -f postgres/pgvector.alpine.Dockerfile
