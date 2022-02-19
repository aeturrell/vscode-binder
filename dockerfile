FROM debian:buster-slim

ENV SHELL /bin/bash
  
# Install system dependencies
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    git \
    screen \
    unzip \
    vim \
    procps \
 && apt-get clean

# Install miniconda
RUN curl -sfLO https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh \
 && /bin/bash Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p /root/miniconda \
 && PATH="/root/miniconda/bin:$PATH" \
 && conda install -c anaconda jupyter jupyterlab notebook

## Code server
RUN mkdir -p ~/.local/lib ~/.local/bin
RUN curl -sfL https://github.com/cdr/code-server/releases/download/v3.9.3/code-server-3.9.3-linux-amd64.tar.gz | tar -C ~/.local/lib -xz
RUN mv ~/.local/lib/code-server-3.9.3-linux-amd64 ~/.local/lib/code-server-3.9.3
RUN ln -s ~/.local/lib/code-server-3.9.3/bin/code-server ~/.local/bin/code-server
RUN PATH="~/.local/bin:$PATH"

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
CMD ~/.local/bin/code-server --bind-addr 0.0.0.0:8080 /${HOME}

# docker build -t jupyter .
# docker run -v $(pwd):/app -p 8080:8080 -p ... -it -d jupyter
# docker exec -it <dontainer_id> cat /root/.config/code-server/config.yaml
