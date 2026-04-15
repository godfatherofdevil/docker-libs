FROM alpine:latest AS build

ARG ORT_VERSION=v1.23.1
ARG ORT_REPO=https://github.com/microsoft/onnxruntime.git

# Build ONNX Runtime natively against musl so the resulting shared library can
# run on Alpine without pulling in glibc compatibility layers.
RUN apk add --no-cache \
    bash \
    build-base \
    ca-certificates \
    cmake \
    coreutils \
    git \
    linux-headers \
    ninja \
    python3 \
    py3-pip \
    zlib-dev

WORKDIR /src

RUN git clone --branch "${ORT_VERSION}" --depth 1 --recursive "${ORT_REPO}" onnxruntime

COPY onnx/overrides /tmp/onnx-overrides

RUN cp -R /tmp/onnx-overrides/onnxruntime/* /src/onnxruntime/onnxruntime/

WORKDIR /src/onnxruntime

RUN ./build.sh \
    --config Release \
    --build_shared_lib \
    --parallel \
    --allow_running_as_root \
    --compile_no_warning_as_error \
    --skip_tests \
    --skip_submodule_sync \
    --cmake_generator Ninja \
    --cmake_extra_defines \
    CMAKE_INSTALL_PREFIX=/opt/onnxruntime \
    BUILD_TESTING=OFF \
    onnxruntime_BUILD_UNIT_TESTS=OFF \
    onnxruntime_ENABLE_ONNX_TESTS=OFF \
    onnxruntime_BUILD_BENCHMARKS=OFF

# Install the built runtime into a predictable prefix so the final stage
# does not need to know the internal build tree layout.
RUN cmake --install /src/onnxruntime/build/Linux/Release --prefix /opt/onnxruntime

FROM alpine:latest

LABEL maintainer="Avinash Kumar avi410vikram@gmail.com"

RUN apk add --no-cache \
    libgcc \
    libstdc++

COPY --from=build /opt/onnxruntime /opt/onnxruntime

ENV LD_LIBRARY_PATH=/opt/onnxruntime/lib

WORKDIR /opt/onnxruntime

CMD ["/bin/sh"]
