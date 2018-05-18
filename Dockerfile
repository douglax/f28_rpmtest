# Defines Docker image suitable for testing cookbooks on CentOS 7. 
# 
# This handles a number of idiosyncrasies with systemd so it can be # run as the root process of the container, making it behave like a 
# normal VM but without the overhead. 
FROM fedora:28 
# Systemd needs to be able to access cgroups 
VOLUME /sys/fs/cgroup 
# Setup container to run Systemd as root process, start an SSH 
# daemon, and provision a user  to connect as. 
RUN yum clean all && \
 #yum -y swap -- remove fakesystemd -- install systemd systemd-libs && \ 
 # Remove unneeded unit files as this container isn't a proper machine
 (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
 rm -f /lib/systemd/system/multi-user.target.wants/* && \
 rm -f /etc/systemd/system/*.wants/* && \
 rm -f /lib/systemd/system/local-fs.target.wants/* && \ 
 rm -f /lib/systemd/system/sockets.target.wants/*udev* && \ 
 rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \ 
 rm -f /lib/systemd/system/basic.target.wants/* && \ 
 rm -f /lib/systemd/system/anaconda.target.wants/* && \ 
 # Setup developr user with passwordless sudo 
 useradd -d /home/developr -m -s /bin/bash developr && \ 
 (echo developr:developr | chpasswd) && \ 
 mkdir -p /etc/sudoers.d && \ 
 echo 'developr ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/developr && \ 
 # Setup SSH daemon so test-kitchen can access the container 
 yum -y install openssh-server openssh-clients && \ 
 ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' && \ 
 ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \ 
 echo 'OPTIONS="-o UseDNS=no -o UsePAM=no -o PasswordAuthentication=yes"' >> /etc/sysconfig/sshd && \ 
 systemctl enable sshd.service 

# Install basic system packages that we expect to exist by default. 
# We do this in a separate RUN command since these packages are more 
# likely to change over time, and we want to reuse previous layers as 
# much as possible.
RUN yum -y install crontabs curl initscripts net-tools passwd sudo tar which 

# Change password for root
RUN echo 'root:devroot' | chpasswd

# Expose port for ssh  
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
