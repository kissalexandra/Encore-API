# The noble image contains the toolchain, compiler etc.
# The noble-slim image used further down is the runtime image.
FROM swift:6.3-noble AS build

WORKDIR /build/

COPY ./Package.swift ./Package.resolved ./
RUN swift package resolve

COPY ./Sources/ ./Sources/
# Required because SwiftPM validates that every target directory exists.
COPY ./Tests/ ./Tests/

RUN swift build -c release --product EncoreApi \
    && mkdir -p /staging/ \
    && cp "$(swift build -c release --show-bin-path)/EncoreApi" /staging/ \
    && strip /staging/EncoreApi

FROM swift:6.3-noble-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 encore \
    && useradd --gid encore --uid 1001 --home /app encore

WORKDIR /app/

COPY --from=build /staging/EncoreApi ./
COPY --chmod=0755 ./docker-entrypoint.sh ./

RUN mkdir -p /app/Storage/ && chown -R encore:encore /app/Storage/

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
