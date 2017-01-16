FROM ubuntu:16.04
MAINTAINER Leonov Andrey

# Update the repository
RUN apt-get update

# Install necessary tools
RUN apt-get install -y nano wget dialog net-tools

# Download and Install Nginx
RUN apt-get install -y nginx

ADD ./conf/ispeak_crm.conf /etc/nginx/sites-available/ispeak_crm.conf
ADD ./conf/nginx-d.conf /etc/nginx/nginx.conf

RUN ["ln", "-s", "/etc/nginx/sites-available/ispeak_crm.conf", "/etc/nginx/sites-enabled/ispeak_crm.conf"]
RUN ["rm", "-rf", "/etc/nginx/sites-available/default"]
CMD ["nginx", "-g", "daemon off;"]

VOLUME ["/var/cache/nginx"]
EXPOSE 80 443