# exit immediately if a simple command exits with a non-zero
set -e

#######################################################################

# assign password to sudo command
echo 'Richard.Liew' | sudo -S ls > /dev/null 2>&1

#######################################################################

# install docker in CentOS system
sudo yum remove -qy \
    docker \
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
sudo yum install -y docker-ce docker-ce-cli containerd.io

#######################################################################

# start docker service
sudo systemctl start docker

#######################################################################

# create environment config file
sudo echo '
VPN_IPSEC_PSK=00000000000000000000
VPN_USER=Richard
VPN_PASSWORD=richard.liew
VPN_ADDL_USERS=u1 u2 u3
VPN_ADDL_PASSWORDS=p1 p2 p3
' > ~/ipsec-vpn.env

#######################################################################

# pull docker images
sudo docker pull hwdsl2/ipsec-vpn-server

# run docker container
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

# copy environment config files to current directory
sudo docker cp ipsec-vpn-server:/etc/ipsec.d/vpn-gen.env ./    # IPSec
sudo docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.p12 ./  # IKEv2

#######################################################################

# check status of docker containers
#sudo docker ps -a

# check logs of container
#sudo docker logs ipsec-vpn-server

# check contents of /etc/ipsec.d in the container
#sudo docker exec -it ipsec-vpn-server ls -l /etc/ipsec.d
