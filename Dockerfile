FROM debian:buster
MAINTAINER Alexandre Duret-Lutz <adl@lrde.epita.fr>
# We have a lot of timeout issues when fetching packages from
# http://httpredir.debian.org/debian so hardcode the OVH mirror.
RUN echo 'deb http://debian.mirrors.ovh.net/debian sid main' > /etc/apt/sources.list && \
    echo 'deb [trusted=true] http://www.lrde.epita.fr/repo/debian/ stable/' >> /etc/apt/sources.list && \
    apt-get update && \
    RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive \
      apt-get install -y --no-install-recommends \
      spot python3-spot \
      python3-pip python3-dev python3-setuptools python3-matplotlib python3-numpy python3-pandas \
      python3-wheel maven \
      build-essential git graphviz fonts-lato \
      wget sudo zip unzip imagemagick ghostscript libbdd0c2 libspot-dev libbddx-dev \
      libbdd-dev man-db less \
      openjdk-11-jre-headless openjdk-11-jdk-headless && \
    set -x && \
    pip3 install jupyter && \
    pip3 install jupyterlab && \
    rm -rf ~/.cache

RUN mkdir -p /home/user && \
    groupadd -g 999 -r user && \
    useradd -u 999 -r -s /bin/bash -g user user && \
    chown user:user /home/user

COPY run-nb /usr/local/bin/run-nb
COPY install.sh /tmp/install.sh
COPY custom.css /home/user/.jupyter/custom/custom.css
RUN ln -s /usr/share/fonts/truetype/lato/Lato-Regular.ttf /home/user/.jupyter/custom/Lato-Regular.ttf
# 2017-01-19: Today's version of Jupyter takes custom.js from ~/.jupyter,
#             and custom.css from ~/.ipython.
RUN mkdir -p /home/user/.ipython && ln -s /home/user/.jupyter/custom /home/user/.ipython/custom
RUN cd /tmp && ./install.sh && rm -f install.sh && chown -R user:user ~user
COPY README.md /home/user/README.md

WORKDIR /home/user
USER user

RUN umask 0002 \
    && ln -s /etc/skel/.bashrc \
    && jupyter notebook --generate-config \
    && echo "c.NotebookApp.token = ''; c.NotebookApp.password = ''" >> .jupyter/jupyter_notebook_config.py \
    && mkdir -p .ipython/profile_default \
    && (echo 'c = get_config()'; echo "c.InteractiveShellApp.matplotlib = 'inline'") > .ipython/profile_default/ipython_kernel_config.py \
    && mkdir -p .local/share/jupyter/runtime \
    && (cd notebooks; for i in *.ipynb; do mv $i tmp-$i; jupyter nbconvert --to notebook tmp-$i --stdout > $i; rm -f tmp-$i; jupyter trust $i; done)

