FROM ubuntu:rolling as docpatch-grundgesetz-build

MAINTAINER Benjamin Heisig <benjamin@heisig.name>

ARG DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Install toolchain:
RUN apt-get update && \
    apt-get dist-upgrade -y
RUN apt-get install -y build-essential curl git gpg quilt texlive-full wget
RUN wget --quiet https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-1-amd64.deb && \
    dpkg -i pandoc-2.5-1-amd64.deb
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g less && \
    npm install -g clean-css && \
    npm install -g less-plugin-clean-css && \
    npm install -g uglify-js
# Install docpatch:
RUN git clone https://github.com/c3e/docpatch.git && \
    cd docpatch/ && \
    ./configure && \
    make && \
    make install
# Clone website repository:
RUN git clone https://github.com/c3e/grundgesetz-web.git && \
    cd grundgesetz-web/ && \
    git submodule init && \
    git submodule update
# Build repository:
RUN cd grundgesetz-web && \
    git config --global user.email "no-reply@bundestag.de" && \
    git config --global user.name "Bundesrepublik Deutschland" && \
    make build
# Create output files:
RUN cd grundgesetz-web/ && \
    make create
# Build website:
RUN cd grundgesetz-web/ && \
    make less && \
    make uglifyjs

FROM nginx:alpine AS docpatch-grundgesetz-web
COPY --from=docpatch-grundgesetz-build /grundgesetz-web/ /usr/share/nginx/html
