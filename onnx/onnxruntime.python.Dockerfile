FROM python:3.12-alpine AS build

ARG ORT_VERSION=v1.23.1
ARG ORT_REPO=https://github.com/microsoft/onnxruntime.git

RUN apk add --no-cache \
    bash \
    build-base \
    ca-certificates \
    cmake \
    coreutils \
    git \
    linux-headers \
    ninja \
    python3-dev \
    zlib-dev

RUN python -m pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel \
    numpy \
    packaging

WORKDIR /src

RUN git clone --branch "${ORT_VERSION}" --depth 1 --recursive "${ORT_REPO}" onnxruntime

COPY onnx/overrides /tmp/onnx-overrides

RUN cp -R /tmp/onnx-overrides/onnxruntime/* /src/onnxruntime/onnxruntime/

WORKDIR /src/onnxruntime

RUN ./build.sh \
    --config Release \
    --build_shared_lib \
    --build_wheel \
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

RUN cmake --install /src/onnxruntime/build/Linux/Release --prefix /opt/onnxruntime

RUN python -m pip install --no-cache-dir /src/onnxruntime/build/Linux/Release/dist/*.whl

RUN mkdir -p /opt/python-site-packages && \
    cp -a /usr/local/lib/python3.12/site-packages/. /opt/python-site-packages/ && \
    rm -rf /usr/local/lib/python3.12/site-packages/*

FROM python:3.12-alpine

LABEL maintainer="Avinash Kumar avi410vikram@gmail.com"

RUN apk add --no-cache \
    libgcc \
    libstdc++

COPY --from=build /opt/onnxruntime /opt/onnxruntime
COPY --from=build /opt/python-site-packages/ /usr/local/lib/python3.12/site-packages/

ENV LD_LIBRARY_PATH=/opt/onnxruntime/lib

WORKDIR /opt/onnxruntime

CMD ["python3"]
