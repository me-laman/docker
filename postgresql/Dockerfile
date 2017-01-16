FROM ubuntu:14.04
MAINTAINER a_leonovv@mail.ru

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.5 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
# && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
# && echo "listen_addresses='*'" >> /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && rm -rf ${PG_HOME} \
 && rm -rf /var/lib/apt/lists/*


COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

#RUN echo "host all  all    0.0.0.0/0  md5" >> ${PG_DATADIR}/pg_hba.conf
## And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
#RUN echo "listen_addresses='*'" >> ${PG_DATADIR}/postgresql.conf

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}"]
WORKDIR ${PG_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"]
