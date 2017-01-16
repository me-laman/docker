FROM buildpack-deps:jessie

# ############
# unprivileged
# ############

# explicitly set user/group IDs
RUN groupadd -r andrey --gid=999 && useradd -m -r -g andrey --uid=999 andrey

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

ENV PYTHON_VERSION 3.5.1

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 8.1.2

RUN set -ex \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& ./configure --enable-shared --enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig \
	&& pip3 install --no-cache-dir --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION \
	&& find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python ~/.cache \
	&& cd /usr/local/bin \
	&& ln -s easy_install-3.5 easy_install3 \
	&& ln -s python3 python

#	&& ln -s idle3 idle \
#	&& ln -s pydoc3 pydoc \
#	&& ln -s python3-config python-config


# ######
# DJANGO + PILLOW
# ######

# https://github.com/docker-library/django/blob/819c332058c3638ab8f4fa5b9f70518e9aaf6325/3.4/Dockerfile
# http://pillow.readthedocs.io/en/3.1.x/installation.html#building-on-linux

RUN apt-get update && apt-get install -y \
        gcc gettext \
        mysql-client libmysqlclient-dev \
        postgresql-client libpq-dev sqlite3 \
        libtiff5-dev zlib1g-dev libfreetype6-dev \
        liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev \
        libxml2-dev libxslt-dev libffi-dev \
      --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# update repos
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update

# install java
RUN apt-get install oracle-java8-installer -y

RUN apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
#
# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

# автоматически активировать virtualenv при логине root
RUN echo "\ncd /opt/project; if [ ! -f env/bin/activate ]; then virtualenv env; fi; . env/bin/activate" >> /root/.bashrc

RUN pip3 install --no-cache-dir --upgrade pip gunicorn psycopg2 mysqlclient virtualenv invoke Jinja2 Pillow

ENV PYTHONUNBUFFERED 1

COPY web_start.sh /opt/web_start.sh
RUN chmod 755 /opt/web_start.sh

RUN mkdir -p /opt/project/app /opt/project/static /opt/project/media /opt/project/cache  && chown -R andrey:andrey /opt/project

# PyCharm хочет исходники в /opt/project
WORKDIR /opt/project/app/ispeak_crmm

COPY requirements.txt opt/project/requirements.txt

RUN pip3 install --no-cache-dir -r opt/project/requirements.txt

ENV STATIC_ROOT /opt/project/static
ENV MEDIA_DIR /opt/project/media
ENV DATA_DIR /opt/project/cache

#COPY . ../app/

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22 8000
#EXPOSE 9200 9300

VOLUME ["/opt/project", "/opt/project/static", "/opt/project/media", "/opt/project/cache"]
#ENTRYPOINT ["/docker-entrypoint.sh"]

#CMD ["/usr/sbin/sshd", "-D"]



