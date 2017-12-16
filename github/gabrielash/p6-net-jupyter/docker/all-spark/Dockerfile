FROM jupyter/all-spark-notebook

USER root


RUN echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/xUbuntu_14.04/ ./" | tee -a /etc/apt/sources.list; \
    wget http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/xUbuntu_14.04/Release.key -O- | apt-key add; \
    apt-get -y update; \.
    apt-get -y install git make binutils gcc libzmq5 libmagickwand-dev libgd-dev libcairo-dev gnuplot


COPY context/start-top.sh /usr/local/bin/
RUN  chmod 755 /usr/local/bin/start-top.sh

ARG DEBIAN_VER=8.9
ARG RAKUDO_VERSION=2017.11
ARG RAKUDO_MINOR=01

ADD https://github.com/nxadm/rakudo-pkg/releases/download/v${RAKUDO_VERSION}/rakudo-pkg-Debian${DEBIAN_VER}_${RAKUDO_VERSION}-${RAKUDO_MINOR}_amd64.deb  /tmp
RUN dpkg -i /tmp/rakudo-pkg*.deb

USER $NB_USER

ENV PATH=/opt/rakudo-pkg/bin:$PATH
ENV LOCAL_HOME=$HOME/.local

RUN mkdir -p ~/.local ;\
    echo "export PATH=~/bin/.perl6:/opt/rakudo-pkg/bin:$PATH" >> ~/.bashrc; \
    echo "export LOCAL_HOME=${HOME}/.local"  >> ~/.bashrc;

RUN /opt/rakudo-pkg/bin/perl6 /opt/rakudo-pkg/bin/install-zef-as-user.p6; \
    cd ~ ;\.
    git clone https://github.com/gabrielash/p6-net-jupyter; \
    cd ~/p6-net-jupyter; \
    /opt/rakudo-pkg/bin/zef install .;

RUN /opt/rakudo-pkg/bin/zef install SVG; \
    /opt/rakudo-pkg/bin/zef install SVG::Plot; \
    /opt/rakudo-pkg/bin/zef install MagickWand; \
    /opt/rakudo-pkg/bin/zef install Image::PNG::Portable; \
    /opt/rakudo-pkg/bin/zef install Chart::Gnuplot; \
    /opt/rakudo-pkg/bin/zef install Cairo; \
    /opt/rakudo-pkg/bin/zef install GD; \
    /opt/rakudo-pkg/bin/zef install Inline::Python

RUN  cd ~/p6-net-jupyter && \
<------>./bin/kernel-install.sh -y

CMD ["start-top.sh"]

