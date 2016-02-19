sudo yum -q -y install screen

# Install JAVA
sudo yum -q -y localinstall /vagrant/jdk-8u73-linux-x64.rpm

# Setting ES version to install
ES_VERSION="elasticsearch-2.2.0"
ES_PLUGIN_INSTALL_CMD="elasticsearch/bin/plugin install"

# Removing all previous potentially installed version
rm -rf elasticsearch
rm -rf elasticsearch-*

# Downloading the version to install
if [ ! -f "/vagrant/$ES_VERSION.tar.gz" ]; then
    wget -q https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.2.0/$ES_VERSION.tar.gz
    tar -zxf $ES_VERSION.tar.gz
    rm -rf $ES_VERSION.tar.gz
else
    tar -zxf /vagrant/$ES_VERSION.tar.gz
fi

# Renaming extracted folder to a generic name to avoid changing ES commands (elasticsearch/bin/...)
mv $ES_VERSION elasticsearch

# Internal ES plugins
# Deprecated
#${ES_PLUGIN_INSTALL_CMD} elasticsearch/elasticsearch-mapper-attachments/3.0.2



# Supervision/Dashboards ES Plugins
${ES_PLUGIN_INSTALL_CMD} mobz/elasticsearch-head
${ES_PLUGIN_INSTALL_CMD} karmi/elasticsearch-paramedic
${ES_PLUGIN_INSTALL_CMD} lukas-vlcek/bigdesk/2.5.0
${ES_PLUGIN_INSTALL_CMD} royrusso/elasticsearch-HQ
${ES_PLUGIN_INSTALL_CMD} lmenezes/elasticsearch-kopf/2.0.0

chown -R vagrant: elasticsearch

sudo systemctl start firewalld.service
sudo systemctl enable firewalld.service
firewall-cmd --zone=public --add-port=9200/tcp --permanent
firewall-cmd --zone=public --add-port=9300/tcp --permanent
sudo systemctl restart firewalld.service