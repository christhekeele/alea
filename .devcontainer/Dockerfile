FROM elixir:1.14.3-slim

ARG USERNAME=vscode

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get install -y vim && \
    apt-get install -y git && \
    apt-get install -y curl && \
    apt-get install -y wget && \
    apt-get install -y gnupg2

ENV MIX_HOME=/root/.mix
ENV HEX_HOME=/root/.hex

RUN mix local.hex --force && \
    mix local.rebar --force
