FROM centos:7
MAINTAINER moremagic<itoumagic@gmail.com>

# Install
RUN yum -y update
RUN yum -y install wget tar java-1.7.0-* tomcat*

# ssh
RUN yum install -y passwd openssh-server initscripts \
	&& echo 'root:root' | chpasswd \
	&& /usr/sbin/sshd-keygen

# tomcat config
RUN sed -i "s#</tomcat-users>##g" /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="manager-gui"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="manager-script"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="manager-jmx"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="manager-status"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="admin-gui"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <role rolename="admin-script"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo ' <user username="admin" password="admin" roles="manager-gui, manager-script, manager-jmx, manager-status, admin-gui, admin-script"/>' >> /usr/share/tomcat/conf/tomcat-users.xml; \
echo '</tomcat-users>' >> /usr/share/tomcat/conf/tomcat-users.xml

# Solr install
RUN wget https://archive.apache.org/dist/lucene/solr/4.10.2/solr-4.10.2.tgz \
	&& tar -zxvf solr-*.tgz \
	&& rm -f solr-*.tgz
RUN cp solr-4.10.2/dist/solr-4.10.2.war /usr/share/tomcat/webapps/ \
	&& cp /solr-4.10.2/example/lib/ext/*.jar /usr/share/tomcat/lib/ \
	&& mkdir /opt/solr \
	&& cp -r /solr-4.10.2/example/solr/collection1 /opt/solr/ \
	&& chown -hR tomcat:tomcat /opt/solr/ \
	&& printf '\
export SOLR_HOME=\"/opt/solr\" \n\
export JAVA_OPTS=\"$JAVA_OPTS -Dsolr.solr.home=${SOLR_HOME}\" \n\
' >> /usr/share/tomcat/conf/tomcat.conf

# debug config
# https://bugzilla.redhat.com/show_bug.cgi?id=1080195
RUN export NAME=tomcat

EXPOSE 22 8080
CMD /usr/sbin/tomcat start; \
	/usr/sbin/sshd -D

