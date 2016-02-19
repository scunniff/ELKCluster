sudo yum -q -y install screen

# Install JAVA
sudo yum -q -y localinstall /vagrant/jdk-8u73-linux-x64.rpm


# Setting ES version to install
LOGSTASH_VERSION="logstash-2.2.1"

# Setting FB version to install
FILEBEAT_VERSION="filebeat-1.1.1-x86_64"
LS_PLUGIN_INSTALL_CMD="logstash/bin/plugin install"

# Removing all previous potentially installed version
rm -rf logstash
rm -rf logstash-*
rm -rf filebeat
rm -rf filebeat-*

# Downloading the version to install
if [ ! -f "/vagrant/$LOGSTASH_VERSION.tar.gz" ]; then
    wget -q https://download.elastic.co/logstash/logstash/${LOGSTASH_VERSION}.tar.gz
    tar -zxf $LOGSTASH_VERSION.tar.gz
    rm -rf $LOGSTASH_VERSION.tar.gz
else
    tar -zxf /vagrant/$LOGSTASH_VERSION.tar.gz
fi

if [ ! -f "/vagrant/$FILEBEAT_VERSION.tar.gz" ]; then
    wget -q https://download.elastic.co/beats/filebeat/${FILEBEAT_VERSION}.tar.gz
    tar -zxf $FILEBEAT_VERSION.tar.gz
    rm -rf $FILEBEAT_VERSION.tar.gz
else
    tar -zxf /vagrant/$FILEBEAT_VERSION.tar.gz
fi

# Renaming extracted folder to a generic name to avoid changing commands 
mv $LOGSTASH_VERSION logstash
mv $FILEBEAT_VERSION filebeat

cp /vagrant/conf/filebeat.yml filebeat/filebeat.yml

${LS_PLUGIN_INSTALL_CMD} logstash-input-beats

chown -R vagrant: logstash

sudo systemctl start firewalld.service
sudo systemctl enable firewalld.service
firewall-cmd --zone=public --add-port=5043/tcp --permanent
firewall-cmd --zone=public --add-port=5514/tcp --permanent
firewall-cmd --zone=public --add-port=5514/udp --permanent
sudo systemctl restart firewalld.service

cd filebeat
sudo ./filebeat -e -c filebeat.yml -d "publish"