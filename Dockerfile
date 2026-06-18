# Reproducible dev/test container for zClip.
#
#   docker build -t zclip .          # build the image
#   docker run --rm zclip            # default: fmt + build + run demo + test
#
# zClip has no system dependencies and needs no display: the C/C++ sources are
# compiled in-tree by Zig's bundled Clang frontend. First `zig build` may fetch
# the pinned toolchain index (network).
FROM ubuntu:24.04
ARG ZIG_VERSION=0.16.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils git python3 \
    && rm -rf /var/lib/apt/lists/*

# Zig, pinned — URL resolved from the official release index.
RUN set -eux; \
    url="$(curl -fsSL https://ziglang.org/download/index.json \
      | python3 -c "import sys,json;print(json.load(sys.stdin)['${ZIG_VERSION}']['x86_64-linux']['tarball'])")"; \
    curl -fsSL "$url" -o /tmp/zig.tar.xz; \
    mkdir -p /opt/zig; tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1; \
    ln -s /opt/zig/zig /usr/local/bin/zig; rm /tmp/zig.tar.xz; zig version

WORKDIR /work
COPY . .

CMD ["bash", "scripts/ci.sh"]
