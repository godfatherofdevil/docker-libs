.PHONY: build_pgvector_alpine
build_pgvector_alpine:
	docker build . -t pgvector-alpine -f postgres/pgvector.alpine.Dockerfile

.PHONY: run_pgvector
run_pgvector:
	docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=secret -v pgvector_data_demo:/var/lib/postgresql/data --name pgvector_demo pgvector-alpine

.PHONY: build_logical_alpine
build_logical_alpine:
	docker build . -t logical-alpine -f postgres/logical.alpine.Dockerfile

.PHONY: run_logical
run_logical:
	docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=secret -v pglogical_demo:/var/lib/postgresql/data --name pglogical_demo logical-alpine

.PHONY: build_onnxruntime_alpine
build_onnxruntime_alpine:
	docker buildx build . -t onnxruntime-alpine -f onnx/onnxruntime.alpine.Dockerfile --load

.PHONY: run_onnxruntime_alpine
run_onnxruntime_alpine:
	docker run --rm -it --name onnxruntime_alpine_demo onnxruntime-alpine
