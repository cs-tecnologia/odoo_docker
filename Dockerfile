FROM python:3.9-slim-buster
#FROM debian:buster-slim
#FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive
#MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV APT_DEPS='build-essential libldap2-dev libpq-dev libsasl2-dev' \
    #PGDATABASE=odoo14-compress \
    LIST_DB=true \
    PIP_ROOT_USER_ACTION=ignore \
    networks=nw-cs

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
#libjpeg8-dev \
    build-essential \
    ca-certificates \
    curl \
    wget \
    default-jre \
    ure \
    dirmngr \
    fonts-noto-cjk \
    fonts-symbola \
    git \
    gnupg \
    gnupg1 \
    gnupg2 \
    pkg-config \
    ldap-utils \
    libcups2-dev \
    libevent-dev \
    libffi-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    liblcms2-dev \
    libldap2-dev \
    libopenjp2-7-dev \
    libjpeg62-turbo \
    libpng-dev \
    libpq-dev \
    libreoffice-java-common \
    libreoffice-writer \
    libsasl2-dev \
    libsnmp-dev \
    libssl-dev \
    libtiff5-dev \
    libwebp-dev \
    libxcb1-dev \
    libxml2-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt1-dev \
    locales \
    node-clean-css \
    nodejs \ 
    node-less \
    npm \
    openssh-client \
    python3 \
    python3-dev \
    python3-dev nodejs \
    python3-lxml \
    python3-num2words \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pip \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-suds \
    python3-venv \
    python3-vobject \
    python3-watchdog \
    python3-wheel \
    python3-xlrd \
    python3-xlwt \
    texlive-fonts-extra \
    xfonts-75dpi \
    xfonts-base \
    xz-utils \
    zlib1g-dev \
    #&& echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' >> /etc/apt/sources.list.d/postgresql.list\
    #&& curl -SL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update -y && apt-get upgrade -y \
    && apt-get install -y libssl1.1 \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
    && /usr/local/bin/python -m pip install --upgrade pip \
    && pip3 install -r https://raw.githubusercontent.com/OCA/OCB/14.0/requirements.txt \
    && pip3 install -r https://raw.githubusercontent.com/OCA/l10n-brazil/14.0/requirements.txt \
    && apt-get -y autoremove 

# definir as configurações locais (Locale) do servidor'
    RUN export LANGUAGE=pt_BR.UTF-8
    RUN export LANG=pt_BR.UTF-8
    RUN LC_ALL=pt_BR.UTF-8
    RUN locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
    RUN dpkg-reconfigure locales
    ARG DEBIAN_FRONTEND=noninteractive
    ENV TZ=America/Sao_Paulo
    RUN apt-get install -y tzdata

# install latest postgresql-client
 RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Add Git Known Hosts
COPY ./ssh_known_git_hosts /root/.ssh/known_hosts

# Install Odoo and remove not French translations and .git directory to limit amount of data used by container
RUN set -x; \
        useradd -l --create-home --home-dir /opt/odoo --no-log-init odoo &&\
        /bin/bash -c "mkdir -p /opt/odoo/{etc,odoo,additional_addons,private_addons,data,private}" &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/OCB.git /opt/odoo/odoo &&\
        rm -rf /opt/odoo/odoo/.git &&\
        #find /opt/odoo/odoo/addons/*/i18n/ /opt/odoo/odoo/odoo/addons/base/i18n/ -type f -not -name 'fr.po' -delete &&\
        chown -R odoo:odoo /opt/odoo

# Install Odoo OCA default dependencies
RUN set -x; \
        git clone -b 14.0 --depth 1 https://github.com/OCA/l10n-brazil.git /opt/odoo/additional_addons/l10n-brazil &&\
        pip3 install -r /opt/odoo/additional_addons/l10n-brazil/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-invoicing.git /opt/odoo/additional_addons/account-invoicing &&\
        pip3 install -r opt/odoo/additional_addons/account-invoicing/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-payment.git /opt/odoo/additional_addons/account-payment &&\
        pip3 install -r /opt/odoo/additional_addons/account-payment/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/bank-payment.git  /opt/odoo/additional_addons/bank-payment &&\
        pip3 install -r /opt/odoo/additional_addons/bank-payment/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/delivery-carrier.git  /opt/odoo/additional_addons/delivery-carrier  &&\
        pip3 install -r /opt/odoo/additional_addons/delivery-carrier/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/mis-builder.git  /opt/odoo/additional_addons/mis-builder &&\
        #pip3 install -r /opt/odoo/additional_addons/mis-builder/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/stock-logistics-workflow.git   /opt/odoo/additional_addons/stock-logistics-workflow   &&\
        pip3 install -r /opt/odoo/additional_addons/stock-logistics-workflow/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-reconcile.git   /opt/odoo/additional_addons/account-reconcile  &&\
        pip3 install -r /opt/odoo/additional_addons/account-reconcile/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/currency.git   /opt/odoo/additional_addons/currency  &&\
        #pip3 install -r /opt/odoo/additional_addons/currency/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/purchase-workflow.git   /opt/odoo/additional_addons/purchase-workflow  &&\
        #pip3 install -r /opt/odoo/additional_addons/purchase-workflow/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/sale-workflow.git   /opt/odoo/additional_addons/sale-workflow   &&\
        pip3 install -r /opt/odoo/additional_addons/sale-workflow/requirements.txt &&\
        #find /opt/odoo/additional_addons/*/i18n/ -type f -not -name 'fr.po' -delete &&\
        chown -R odoo:odoo /opt/odoo

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /opt/odoo/etc/odoo.conf
RUN chown odoo:odoo /opt/odoo/etc/odoo.conf

# Mount /opt/odoo/data to allow restoring filestore
VOLUME ["/opt/odoo/data/"]

# Expose Odoo services
EXPOSE 8069

# Set default user when running the container
USER odoo

# Start
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

# Metadata
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
LABEL org.label-schema.schema-version="$VERSION" \
      org.label-schema.vendor=LeFilament \
      org.label-schema.license=Apache-2.0 \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="https://github.com/lefilament/docker-odoo"
