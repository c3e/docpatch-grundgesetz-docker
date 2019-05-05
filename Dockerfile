FROM ubuntu:rolling as docpatch-grundgesetz-build

MAINTAINER Benjamin Heisig <benjamin@heisig.name>

ARG DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Install toolchain:
RUN set -ex; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        curl \
        git \
        gpg \
        gpg-agent \
        quilt \
        texlive-full \
        wget
RUN set -ex; \
    mkdir /pandoc; \
    cd /pandoc; \
    download=$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep 'browser_' | cut -d\" -f4 |grep deb); \
    wget $download; \
    apt install ./*.deb; \
    pandoc --version
    
#RUN set -ex; \
#    cabal --version; \
#    cabal update; \
#    cabal install --global cabal-install; \
#    cabal --version; \
#    cabal install --global pandoc; \
#    pandoc --version
RUN set -ex; \
    curl -sL https://deb.nodesource.com/setup_10.x | bash -; \
    apt-get install -y nodejs --no-install-recommends; \
    npm install -g less; \
    npm install -g clean-css; \
    npm install -g less-plugin-clean-css; \
    npm install -g uglify-js
# Remove apt index
RUN set -ex; \
    rm -rf /var/lib/apt/lists/*
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
    git submodule update --remote --merge
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
# Build website and clean up:
RUN set -ex; \
    cd grundgesetz-web/; \
    make less; \
    make uglifyjs; \
    rm -rf .git/; \
    rm .gitignore; \
    rm .gitmodules; \
    rm Makefile; \
    rm grundgesetz-dev/.editorconfig; \
    rm -rf grundgesetz-dev/.git/; \
    rm grundgesetz-dev/.gitignore; \
    rm -rf grundgesetz-dev/repo/.git/

FROM nginx:alpine AS docpatch-grundgesetz-web

COPY --from=docpatch-grundgesetz-build /grundgesetz-web/ /usr/share/nginx/html
