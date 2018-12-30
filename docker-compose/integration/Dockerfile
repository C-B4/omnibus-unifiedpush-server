FROM centos:7
MAINTAINER CB4 <support@cb4.com>
RUN yum update -y && yum install -y java-1.8.0-openjdk \
	net-tools \
        openssh-server \
        openssl-devel \
	systemd \
	iproute \
	git

# Add jenkins user
RUN useradd -ms /bin/bash jenkins -d /var/lib/jenkins
RUN echo "jenkins:jenkins" | chpasswd
# Set root password
RUN echo "root:jenkins" | chpasswd

# Set up SSH 
RUN mkdir /var/run/sshd && mkdir /var/log/ssh

# Set up SSH Host Key
RUN /usr/bin/ssh-keygen -q -t rsa1 -f /etc/ssh/ssh_host_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_key && chmod 644 /etc/ssh/ssh_host_key.pub
RUN /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_rsa_key && chmod 644 /etc/ssh/ssh_host_rsa_key.pub
RUN /usr/bin/ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_dsa_key && chmod 644 /etc/ssh/ssh_host_dsa_key.pub
RUN /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_ecdsa_key && chmod 644 /etc/ssh/ssh_host_ecdsa_key.pub
RUN /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_ed25519_key && chmod 644 /etc/ssh/ssh_host_ed25519_key.pub

# Set up SSHD config
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd  
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Install systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN systemctl enable sshd.service

# Install UPS/KC
ADD /download.sh /tmp/download.sh
RUN /tmp/download.sh
RUN rpm -i unifiedpush-server*.rpm
RUN rpm -i keycloak-server*.rpm

# Install config-setup.sh but use it only after hostname is properly set
COPY /config-setup.sh /tmp/config-setup.sh
COPY /install-lets-encrypt.sh /tmp/install-lets-encrypt.sh

# Standard SSH port
EXPOSE 22 80 443
CMD ["/usr/sbin/init"]
