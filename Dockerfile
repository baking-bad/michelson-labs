FROM python:3.7-slim-buster

ARG NB_USER=mickey
ARG NB_UID=1000

USER root

RUN apt update && \
    apt install -y build-essential pkg-config libsodium-dev libsecp256k1-dev libgmp-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install notebook jupyter-client pytezos
RUN michelson-kernel install

ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

COPY notebooks/ ${HOME}/notebooks
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}/

WORKDIR ${HOME}
USER ${USER}

EXPOSE 8888
ENTRYPOINT []