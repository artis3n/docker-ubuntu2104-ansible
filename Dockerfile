FROM ubuntu:21.04
LABEL maintainer="artis3n"

ARG pip_packages="ansible"

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-utils \
    locales \
    python3-setuptools \
    python3-pip \
    software-properties-common \
    rsyslog \
    systemd \
    systemd-cron \
    sudo \
    iproute2 \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man \
    && sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible \
  && printf "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install Ansible via Pip.
RUN pip3 install --no-cache-dir $pip_packages

WORKDIR /
COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
