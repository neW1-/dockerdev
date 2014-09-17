FROM centos:centos6
MAINTAINER Martin Markovski <markovski.martin@gmail.com>

# Update base images.
RUN yum distribution-synchronization -y

# Install EPEL, MySQL, Zabbix release packages.
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

RUN yum makecache
# Installing SNMP Utils
#RUN yum -y install libsnmp-dev libsnmp-base libsnmp-dev libsnmp-perl libnet-snmp-perl librrds-perl
RUN yum -y -q install net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils
# Install Lamp Stack, including PHP5 SNMP
RUN yum -y -q install mysql mysql-server
# Additional Tools
RUN yum -y -q install passwd perl-JSON pwgen vim
# Install packages.
RUN yum -y -q install java-1.7.0-openjdk
# Install zabbix proxy
RUN yum -y -q install zabbix22-agent zabbix22-java-gateway zabbix22-proxy zabbix22-proxy-mysql
# Install database files, please not version number in the package (!)
RUN yum -y -q install zabbix22-dbfiles-mysql
# install monit
RUN yum -y -q install monit
# Cleaining up.
RUN yum clean all
# MySQL
#RUN service mysqld start && chkconfig myslqd
# Zabbix Conf Files
ADD ./zabbix/zabbix.ini                                 /etc/php.d/zabbix.ini
ADD ./zabbix/httpd_zabbix.conf                  /etc/httpd/conf.d/zabbix.conf
ADD ./zabbix/zabbix.conf.php                    /etc/zabbix/web/zabbix.conf.php
ADD ./zabbix/zabbix_agentd.conf                 /etc/zabbix/zabbix_agentd.conf
ADD ./zabbix/zabbix_java_gateway.conf   /etc/zabbix/zabbix_java_gateway.conf
ADD ./zabbix/zabbix_server.conf                 /etc/zabbix/zabbix_server.conf

RUN chmod 640 /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf

# Monit
ADD ./monitrc /etc/monitrc
RUN chmod 600 /etc/monitrc

# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Add the script that will start the repo.
ADD ./scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# Expose the Ports used by
# * Zabbix services
# * Monit
EXPOSE 10051 10050 2812

VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d", "/etc/zabbix/zabbix_proxyd.d"]
CMD ["/bin/bash", "/start.sh"]
