FROM rakudo-star

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm-256color

RUN         apt-get update -q \
        &&  apt-get install --no-install-recommends -qy \
                apt-transport-https apt-utils ca-certificates gnupg2 wget \
        &&  sh -c 'echo deb https://packages.sury.org/php/ jessie main | tee /etc/apt/sources.list.d/sury.list' \
        &&  wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add - \
        &&  apt-get update -q \
        &&  apt-get install --no-install-recommends -qy \
                git libssl-dev unzip zip \
                &&  zef install App::Mi6 \
        &&  apt-get clean \
        &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY    . .

RUN     zef --deps-only install .