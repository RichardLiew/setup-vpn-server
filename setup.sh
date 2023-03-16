# exit immediately if a simple command exits with a non-zero
set -e

# install docker in CentOS system
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-nightly
sudo yum makecache fast
sudo yum install docker-ce docker-ce-cli containerd.io

# start docker service
sudo systemctl start docker

# create environment config file
sudo echo -e \
'VPN_IPSEC_PSK=00000000000000000000\n'\
'VPN_USER=Richard\n'\
'VPN_PASSWORD=richard.liew\n'\
'VPN_ADDL_USERS=u1 u2 u3\n'\
'VPN_ADDL_PASSWORDS=p1 p2 p3\n'\
> ~/ipsec-vpn.env

# pull the docker images
sudo docker pull hwdsl2/ipsec-vpn-server

# run the docker container
sudo docker run \
    --name ipsec-vpn-server \
    --env-file ./ipsec-vpn.env \
    --restart=always \
    -v ikev2-vpn-data:/etc/ipsec.d \
    -v /lib/modules:/lib/modules:ro \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d \
    --privileged \
    hwdsl2/ipsec-vpn-server
