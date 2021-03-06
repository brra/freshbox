#!/bin/bash

# Docker repo key
echo "Adding docker repository key"
if [ "$DISTRO" == "ubuntu" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
elif [ "$DISTRO" == "debian" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
fi



# Docker repo to source list
echo "Adding docker to sources list"
if [ "$DISTRO" == "ubuntu" ]; then
    sudo add-apt-repository -y \
       "deb https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
elif [ "$DISTRO" == "debian" ]; then
    sudo add-apt-repository -y \
   "deb https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
fi

# install Docker
echo "Installing docker"
sudo apt-get update

if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    sudo -E apt-get install -y docker-ce docker-ce-cli containerd.io cgroupfs-mount
fi

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Docker group
sudo usermod -aG docker brra
mkdir -p /etc/systemd/system/docker.service.d
# Restart docker.
systemctl daemon-reload
systemctl restart docker
# Enable packet forwarding
# configure sysctl
modprobe overlay
modprobe br_netfilter

# Docker Compose
echo "Installing Docker Compose"
#if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
#    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#    sudo chmod +x /usr/local/bin/docker-compose
#elif [ "$DISTRO" == "raspbian" ]; then
# Install required packages
#sudo -E apt install -y python-backports.ssl-match-hostname

# Install Docker Compose from pip
# This might take a while
# cryptography >=3.4 requires rust to compile, and no rust compiler is readily available for ARM
sudo pip3 install cryptography==3.3.2 docker-compose
#fi

