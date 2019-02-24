FROM ubuntu:rolling as docpatch-grundgesetz-build

MAINTAINER Benjamin Heisig <benjamin@heisig.name>

ARG DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Install toolchain:
RUN set -ex; \
    apt-get update; \
    apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        gpg \
        haskell-platform \
        quilt \
        texlive-full \
        wget
RUN set -ex; \
    cabal --version; \
    cabal update; \
    cabal install --global cabal-install; \
    cabal --version; \
    cabal install --global pandoc; \
    pandoc --version
RUN set -ex; \
    apt-get install -y apt-utils gpg-agent; \
    curl -sL https://deb.nodesource.com/setup_10.x | bash -; \
    apt-get install -y nodejs; \
    npm install -g less; \
    npm install -g clean-css; \
    npm install -g less-plugin-clean-css; \
    npm install -g uglify-js
# Install docpatch:
RUN set -ex; \
    git clone https://github.com/c3e/docpatch.git; \
    cd docpatch/; \
    ./configure; \
    make; \
    make install
# Clone website repository:
RUN set -ex; \
    git clone https://github.com/c3e/grundgesetz-web.git; \
    cd grundgesetz-web/; \
    git submodule init; \
    git submodule update
# Build repository:
RUN set -ex; \
    cd grundgesetz-web; \
    git config --global user.email "no-reply@bundestag.de"; \
    git config --global user.name "Bundesrepublik Deutschland"; \
    make build
# Create output files:
RUN set -ex; \
    cd grundgesetz-web/; \
    make create
# Build website:
RUN set -ex; \
    cd grundgesetz-web/; \
    make less; \
    make uglifyjs

FROM nginx:alpine AS docpatch-grundgesetz-web
COPY --from=docpatch-grundgesetz-build /grundgesetz-web/ /usr/share/nginx/html
