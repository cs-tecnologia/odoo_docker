#FROM python:3.10-slim-buster
FROM python:3.10-bullseye

ENV APT_DEPS='build-essential libldap2-dev libpq-dev libsasl2-dev' \
   PIP_ROOT_USER_ACTION=ignore 
   #LANG=pt_BR.UTF-8 \
   #LC_ALL=pt_BR.UTF-8 
   #PGDATABASE=odoo14-compress

# definir as configurações locais (Locale) do servidor'
    RUN dpkg-reconfigure tzdata
    RUN echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
    RUN export LANGUAGE=pt_BR.UTF-8
    RUN export LANG=pt_BR.UTF-8
    RUN LC_ALL=pt_BR.UTF-8
    #RUN locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
    #RUN dpkg-reconfigure locales
    ARG DEBIAN_FRONTEND=noninteractive
    ENV TZ=America/Sao_Paulo
    RUN apt-get install -y tzdata


RUN set -x; \
        apt-get update -y && apt-get upgrade -y &&\
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
    zlib1g-dev  &&\
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' >> /etc/apt/sources.list.d/postgresql.list &&\
        curl -SL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
        #curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb &&\
        #echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - &&\
        wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb &&\
        apt-get update &&\
        apt-get install -y --no-install-recommends ./wkhtmltox_0.12.6.1-2.bullseye_amd64.deb &&\
        apt-get install -y --no-install-recommends postgresql-client &&\
        apt-get install -y --no-install-recommends ${APT_DEPS} &&\
        apt-get install --reinstall ca-certificates &&\
        /usr/local/bin/python -m pip install --upgrade pip &&\
        pip3 install -r https://raw.githubusercontent.com/OCA/OCB/14.0/requirements.txt &&\
        pip3 install phonenumbers simplejson gevent PyYAML zxcvbn &&\
        apt-get -y purge ${APT_DEPS} &&\
        apt-get -y autoremove &&\
        rm -rf /var/lib/apt/lists/* wkhtmltox_0.12.6.1-2.bullseye_amd64.deb
# Add Git Known Hosts
COPY ./ssh_known_git_hosts /root/.ssh/known_hosts

# Install Odoo and remove not French translations and .git directory to limit amount of data used by container
RUN set -x; \
        useradd -l --create-home --home-dir /opt/odoo --no-log-init odoo &&\
        /bin/bash -c "mkdir -p /opt/odoo/{etc,log,odoo,additional_addons,private_addons,data,private}" &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/OCB.git /opt/odoo/odoo &&\
        rm -rf /opt/odoo/odoo/.git &&\
        chown -R odoo:odoo /opt/odoo

# Install Odoo OCA default dependencies
RUN set -x; \
        git clone -b 14.0 --depth 1 https://github.com/OCA/l10n-brazil.git /opt/odoo/additional_addons/l10n-brazil &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-invoicing.git /opt/odoo/additional_addons/account-invoicing &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-payment.git /opt/odoo/additional_addons/account-payment &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/bank-payment.git  /opt/odoo/additional_addons/bank-payment &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/delivery-carrier.git  /opt/odoo/additional_addons/delivery-carrier  &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/mis-builder.git  /opt/odoo/additional_addons/mis-builder &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/stock-logistics-workflow.git   /opt/odoo/additional_addons/stock-logistics-workflow   &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-reconcile.git   /opt/odoo/additional_addons/account-reconcile  &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/currency.git   /opt/odoo/additional_addons/currency  &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/purchase-workflow.git   /opt/odoo/additional_addons/purchase-workflow  &&\
        git clone -b 14.0 --depth 1 https://github.com/OCA/sale-workflow.git   /opt/odoo/additional_addons/sale-workflow   &&\
      #
        pip3 install -r /opt/odoo/additional_addons/l10n-brazil/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/account-invoicing/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/account-payment/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/bank-payment/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/delivery-carrier/requirements.txt &&\
        #pip3 install -r /opt/odoo/additional_addons/mis-builder/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/stock-logistics-workflow/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/account-reconcile/requirements.txt &&\
        #pip3 install -r /opt/odoo/additional_addons/currency/requirements.txt &&\
        #pip3 install -r /opt/odoo/additional_addons/purchase-workflow/requirements.txt &&\
        pip3 install -r /opt/odoo/additional_addons/sale-workflow/requirements.txt \
        && pip install pyOpenSSL==20.0.1 \
        && pip install signxml==2.9 \
        && pip install certifi==2022.9.24 \
        && pip install signxml==2.9 \
        && pip install certifi==2022.9.24 \
        && pip install acme==1.32.0 \
        && pip install astor==0.8.1 \
        && pip install Avalara==22.11.0 \
        && pip install bcrypt==4.0.1 \
        && pip install cryptography==38.0.3 \
        && pip install dataclasses==0.6 \
        && pip install dicttoxml==1.7.4 \
        && pip install et-xmlfile==1.1.0 \
        && pip install josepy==1.13.0 \
        && pip install multidict==6.0.2 \
        && pip install OdooRPC==0.9.0 \
        && pip install openpyxl==3.0.10 \
        && pip install openupgradelib==3.3.4 \
        && pip install paramiko==2.12.0 \
        && pip install phonenumbers==8.13.0 \
        && pip install PyMeeus==0.5.11 \
        && pip install PyNaCl==1.5.0 \
        && pip install pyRFC3339==1.1 \
        && pip install pysftp==0.2.8 \
        && pip install pytz==2022.6 \
        && pip install sentry-sdk==1.11.0 \
        && pip install urllib3==1.26.12 \
        && pip install yarl==1.8.1 \
        && pip install zope.interface==5.5.1 \       
        && pip3 install --upgrade setuptools \
        && pip3 install python3-cnab \
        && pip3 install py-Asterisk \
        && pip3 install psycopg2-binary \
        && pip3 install aiohttp \       
      #
        && chown -R odoo:odoo /opt/odoo

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
