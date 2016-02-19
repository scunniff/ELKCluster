@kibana_start_inline_script = <<SCRIPT
if ! cat /etc/profile | grep -q vagrant
then
    cat <<EOT >> /etc/profile.d/vagrant-elasticsearch-kibana.sh

export VM_NAME=%s
export VM_NODE_NAME=%s
export VM_NODE_IP=%s
export PATH=/vagrant/scripts:/home/vagrant/kibana/bin:\\$PATH
EOT

    sed 's#^.*secure_path="\\(.*\\)"$#Defaults secure_path="\\1:/vagrant/scripts:/home/vagrant/kibana/bin"#' -i /etc/sudoers
    echo 'Defaults env_keep = "VM_NAME"' >> /etc/sudoers

    source /etc/profile
fi

screen -li | grep -q kibana || kibana-start
SCRIPT
