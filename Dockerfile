FROM rancher/docker-dind-base:v0.4.1

MAINTAINER Bill Maxwell "<bill@rancher.com>"

RUN apt-get update && apt-get -y install git openssh-server

RUN sed -i 's/PermitRootLogin\ without-password/PermitRootLogin\ no/' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd

RUN useradd -m -d /opt/dolly dolly
RUN usermod -aG docker dolly
RUN cd /opt/dolly && mkdir .ssh && chmod 700 .ssh && chown -R dolly:dolly .ssh
RUN mkdir -p /opt/dolly/locals && chown dolly:dolly /opt/dolly/locals
RUN mkdir -p /opt/dolly/remotes && chown dolly:dolly /opt/dolly/remotes

COPY ./hacks/run.sh /scripts/run.sh
COPY ./hacks/post-receive /scripts/post-receive

VOLUME /opt/dolly/remotes

EXPOSE 22

ENTRYPOINT [ "/scripts/run.sh" ]
