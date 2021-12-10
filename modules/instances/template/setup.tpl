#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log) 2>&1

# Set local/private IP address
local_ipv4="$(echo -e `hostname -I` | tr -d '[:space:]')"
local_hostname="$('hostname')"
CRDB_REGION=${region}
CRDB_ZONE=${zone}

#######################
# Prepare non-boot disk
#######################

logger "Mounting and formatting 2nd drive"

MNT_DIR=/mnt/disks/persistent_storage

if [[ -d "$MNT_DIR" ]]; then
        exit
else 
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb; \
        sudo mkdir -p $MNT_DIR
        sudo mount -o discard,defaults /dev/sdb $MNT_DIR

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value /dev/sdb` $MNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
fi

#######################
# Install Prerequisites
#######################

logger "Installing jq"

sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq1

logger  "Setting timezone to Europe/Berlin"
sudo timedatectl set-timezone Europe/Berlin

logger "Performing updates and installing prerequisites"
sudo apt-get -qq -y update
sudo apt-get install -qq -y wget unzip dnsutils ntp
sudo systemctl start ntp.service
sudo systemctl enable ntp.service

logger "Completed Installing Prerequisites"

###########################################
# Vault Integration - Sourcing Certificates
###########################################

logger "Downloading Vault Agent"

sudo mkdir /vault

wget -P /vault https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip

sudo unzip -o /vault/vault_${vault_version}_linux_amd64.zip -d /vault
sudo cp /vault/vault /usr/local/bin/

logger "Writing templates and agent config"

sudo tee /vault/agent.hcl <<EOF
exit_after_auth = true
pid_file = "./pidfile"

auto_auth {
  method "gcp" {
      mount_path = "auth/gcp"
      namespace = "admin"
      config = {
          type = "iam"
          role = "crdb"
          jwt_exp = "5"
          service_account = "${service_account}"
          project= "${project_id}"
      }
  }

  sink "file" {
      config = {
          path = "/vault/vault-token"
      }
  }
}

vault {
  address = "${vault_addr}"
}

template {
  source      = "/vault/node_cert.tmpl"
  destination = "/vault/node.crt"
}

template {
  source      = "/vault/node_key.tmpl"
  destination = "/vault/node.key"
}

template {
  source      = "/vault/ca_cert.tmpl"
  destination = "/vault/ca.crt"
}

# template {
#   source      = "/vault/ear.tmpl"
#   destination = "/vault/ear.key"
# }

template {
  source      = "/vault/user_cert.tmpl"
  destination = "/vault/client.root.crt"
}

template {
  source      = "/vault/user_key.tmpl"
  destination = "/vault/client.root.key"
}

template {
  source      = "/vault/ui_cert.tmpl"
  destination = "/vault/ui.crt"
}

template {
  source      = "/vault/ui_key.tmpl"
  destination = "/vault/ui.key"
}
EOF

sudo tee /vault/ca_cert.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=node" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}
EOF

sudo tee /vault/node_cert.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=node" "alt_names=$${local_hostname},localhost" "ip_sans=$${local_ipv4},127.0.0.1" "ttl=24h"}}
{{ .Data.certificate }}
{{ end }}
EOF

sudo tee /vault/node_key.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=node" "alt_names=$${local_hostname},localhost" "ip_sans=$${local_ipv4},127.0.0.1" "ttl=24h"}}
{{ .Data.private_key }}
{{ end }}
EOF

sudo tee /vault/user_cert.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=root" "ttl=24h"}}
{{ .Data.certificate }}
{{ end }}
EOF

sudo tee /vault/user_key.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=root" "ttl=24h"}}
{{ .Data.private_key }}
{{ end }}
EOF

sudo tee /vault/ui_cert.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=ui" "ttl=24h"}}
{{ .Data.certificate }}
{{ end }}
EOF

sudo tee /vault/ui_key.tmpl <<EOF
{{ with secret "pki/issue/crdb_node" "common_name=ui" "ttl=24h"}}
{{ .Data.private_key }}
{{ end }}
EOF

logger "Executing Vault Agent to fetch secrets"

sudo /vault/vault agent -config=/vault/agent.hcl

#################
# Set up CRDB user
#################

logger "Adding CockroachDB user"

sudo useradd --system --home /etc/crdb.d --shell /bin/false crdb

############################
# Install and configure crdb
############################

logger "Downloading CockroachDB"

mkdir /tmp
wget -P /tmp https://binaries.cockroachdb.com/cockroach-${crdb_version}.linux-amd64.tgz

logger "Installing CockroachDB"

sudo tar -xzf /tmp/cockroach-${crdb_version}.linux-amd64.tgz -C /tmp/
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/cockroach /usr/local/bin/

sudo chmod 0755 /usr/local/bin/cockroach
sudo chown crdb:crdb /usr/local/bin/cockroach

sudo mkdir -p /usr/local/lib/cockroach
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/
sudo chown crdb:crdb /usr/local/lib/cockroach/libgeos.so
sudo chown crdb:crdb /usr/local/lib/cockroach/libgeos_c.so 

sudo mkdir -pm 0755 /etc/crdb.d
sudo mkdir -pm 0755 /mnt/disks/persistent_storage/crdb/data
# sudo mkdir -pm 0755 /opt/crdb/data
sudo chown crdb:crdb /mnt/disks/persistent_storage/crdb/data

###################################################
# Generating Encryption Key and copying it to Vault
###################################################

logger "Creating Encryption Key"

cockroach gen encryption-key -s 128 /vault/aes-256.key

logger "Uploading Encryption Key to Vault"

export VAULT_TOKEN=$(cat /vault/vault-token)
export VAULT_ADDR=${vault_addr}

echo $(cat /vault/aes-256.key) | base64 > /vault/encoded.txt
vault kv put -namespace=admin secret/crdb/ encryption_key=$(cat /vault/encoded.txt)

logger "Modifying permissions for certificate files"

sudo chown -R crdb:crdb /vault/*
sudo chmod 700 /vault/node.*
sudo chmod 700 /vault/client.*
sudo chmod 700 /vault/ca.crt
sudo chmod 700 /vault/ui.*
sudo chmod 700 /vault/aes-256.key

#############################
# Create crdb Systemd Service
#############################

logger "Registering CockroachDB daemon"

sudo sudo touch /etc/systemd/system/crdb.service
sudo chmod 0664 /etc/systemd/system/crdb.service
sudo tee /etc/systemd/system/crdb.service <<EOF
[Unit]
Description=crdb
Requires=network-online.target
After=network-online.target
[Service]
Restart=on-failure
ExecStart=/usr/local/bin/cockroach start --join=crdb-node-1:26257,crdb-node-2:26257,crdb-node-3:26257 --store=/mnt/disks/persistent_storage/crdb/data  --locality=region=${region},zone=${zone} --certs-dir=/vault --enterprise-encryption=path=/mnt/disks/persistent_storage/crdb/data,key=/vault/aes-256.key,old-key=plain
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=crdb
Group=crdb
[Install]
WantedBy=multi-user.target
EOF

logger "Starting CockroachDB daemon"

sudo systemctl enable crdb
sudo systemctl start crdb
sudo systemctl status crdb

logger "Completed Configuration of Cockroach Node, not initialized yet!"