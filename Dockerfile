FROM centos:centos7
MAINTAINER Andreas Krüger

# Deps from: https://github.com/sipcapture/homer/blob/master/scripts/extra/homer_installer.sh
RUN yum install -y autoconf automake bzip2 cpio curl curl-devel curl-devel \
                   expat-devel fileutils make gcc gcc-c++ gettext-devel gnutls-devel openssl \
                   openssl-devel openssl-devel mod_ssl perl patch unzip wget zip zlib zlib-devel \
                   bison flex mysql mysql-devel pcre-devel libxml2-devel sox httpd php php-gd php-mysql php-json

# Clone the source
RUN mkdir -p /usr/src/
WORKDIR /usr/src/
RUN git clone -b 4.2 --depth 1 https://github.com/kamailio/kamailio.git kamailio

WORKDIR /usr/src/kamailio
RUN git checkout 4.2
ENV REAL_PATH /usr/local/kamailio

# Get ready for a build.
RUN make PREFIX=$REAL_PATH FLAVOUR=kamailio include_modules="db_mysql sipcapture pv textops rtimer xlog sqlops htable sl siputils" cfg
RUN make all && make install
RUN mv $REAL_PATH/etc/kamailio/kamailio.cfg $REAL_PATH/etc/kamailio/kamailio.cfg.old
RUN cp modules/sipcapture/examples/kamailio.cfg $REAL_PATH/etc/kamailio/kamailio.cfg

WORKDIR /

# Get the configs in there
RUN mkdir -p /etc/kamailio
COPY kamailio.cfg /etc/kamailio/kamailio.cfg
COPY run.sh /run.sh
ENTRYPOINT [ "/run.sh" ]
