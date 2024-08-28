#!/bin/bash

echo -e "\033[1;36m"
echo -e "░██████╗░███████╗░░░░░░███████╗██╗░░░░░░█████╗░████████╗██╗░█████╗░███╗░░██╗░█████╗░██████╗░███████╗░██████╗"
echo -e "██╔════╝░╚════██║░░░░░░██╔════╝██║░░░░░██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔══██╗██╔══██╗██╔════╝██╔════╝"
echo -e "██║░░██╗░░░░░██╔╝█████╗█████╗░░██║░░░░░███████║░░░██║░░░██║██║░░██║██╔██╗██║██║░░██║██║░░██║█████╗░░╚█████╗░"
echo -e "██║░░╚██╗░░░██╔╝░╚════╝██╔══╝░░██║░░░░░██╔══██║░░░██║░░░██║██║░░██║██║╚████║██║░░██║██║░░██║██╔══╝░░░╚═══██╗"
echo -e "╚██████╔╝░░██╔╝░░░░░░░░███████╗███████╗██║░░██║░░░██║░░░██║╚█████╔╝██║░╚███║╚█████╔╝██████╔╝███████╗██████╔╝"
echo -e "░╚═════╝░░░╚═╝░░░░░░░░░╚══════╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝╚═════╝░"
echo -e "\033[1;34m"
echo
echo -e "\033[1;32mG7 community: \033[5;31mhttps://t.me/g7monitor\033[0m"
echo -e "\033[1;32mElatioNodes community: \033[5;31mhttps://discord.gg/KvQGajqDUW\033[0m"
echo -e "\033[0m"

# Checking and installing Docker
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker успешно установлен."
else
    echo "Docker is already installed. Skip the installation."
fi

# Package Update
sudo apt update && sudo apt upgrade -y

# Installing the necessary packages
sudo apt install screen curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar net-tools clang git ncdu pkg-config libssl-dev -y

# Install NodeJS & NPM (version 20.16.1 minimum)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Typesense installation (API KEY is 'xyz' by default, you can change it)
export TYPESENSE_API_KEY=xyz
    
sudo mkdir "$(pwd)"/typesense-data

sudo docker run -d -p 8108:8108 \
            -v "$(pwd)"/typesense-data:/data typesense/typesense:26.0 \
            --data-dir /data \
            --api-key=$TYPESENSE_API_KEY \
            --enable-cors

# Check if the ocean-node folder already exists
if [ ! -d "ocean-node" ]; then
    sudo git clone https://github.com/oceanprotocol/ocean-node.git
fi

cd ocean-node

# Checking for a Dockerfile
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile not found in ocean-node folder."
    exit 1
fi

# Check if the image is available and build it if necessary
if [[ "$(sudo docker images -q ocean-node:mybuild 2> /dev/null)" == "" ]]; then
    echo "Docker image build..."
    sudo docker build -t ocean-node:mybuild .
    if [[ $? -ne 0 ]]; then
        echo "Error: Image build failed."
        exit 1
    fi
else
    echo "The ocean-node:mybuild image already exists."
fi

# Запрос приватного ключа у пользователя
read -p "ВEnter your private key (in the format 0x...): " PRIVATE_KEY

# Запрос IP-адреса у пользователя
read -p "Enter the IP address of your server: " SERVER_IP

# Запрос адреса кошелька 
read -p "Enter the address of the wallet from which you will enter the admin panel: " ADMIN_ADDRESS

# Создание .env файла
cat <<EOF > .env
# Environmental Variables

#check env.md file for examples and descriptions on each variable

#----------------- REQUIRED --------------------------
#This is the only required/mandatory variable
#Node will simply not run without this variable
#All the other variables can remain blank (because they have defaults) or simply commented
PRIVATE_KEY=$PRIVATE_KEY
#-----------------------------------------------------

## core
INDEXER_NETWORKS=["23295", "11155420"]
RPCS={"23295":{"rpc":"https://testnet.sapphire.oasis.io","chainId":23295,"network":"oasis_saphire_testnet","chunkSize":100},"11155420":{"rpc":"https://sepolia.optimism.io","chainId":11155420,"network":"optimism-sepolia","chunkSize":100}}
DB_URL=http://$SERVER_IP:8108/?apiKey=xyz
IPFS_GATEWAY=https://ipfs.io/
ARWEAVE_GATEWAY=https://arweave.net/
LOAD_INITIAL_DDOS=
FEE_TOKENS=
FEE_AMOUNT=
ADDRESS_FILE=
NODE_ENV=
AUTHORIZED_DECRYPTERS=
OPERATOR_SERVICE_URL=
INTERFACES=["HTTP","P2P"]
ALLOWED_VALIDATORS=
INDEXER_INTERVAL=
ALLOWED_ADMINS=["$ADMIN_ADDRESS"]
DASHBOARD=true
RATE_DENY_LIST=
MAX_REQ_PER_SECOND=
MAX_CHECKSUM_LENGTH=
LOG_LEVEL=
HTTP_API_PORT=8000

## p2p

P2P_ENABLE_IPV4=true
P2P_ENABLE_IPV6=false
P2P_ipV4BindAddress=0.0.0.0
P2P_ipV4BindTcpPort=9000
P2P_ipV4BindWsPort=9001
P2P_ipV6BindAddress=::
P2P_ipV6BindTcpPort=9002
P2P_ipV6BindWsPort=9003
P2P_ANNOUNCE_ADDRESSES=["/dns4/$SERVER_IP/tcp/9000/p2p/YOUR_NODE_ID_HERE", "/dns4/$SERVER_IP/ws/tcp/9001", "/dns6/$SERVER_IP/tcp/9002/p2p/YOUR_NODE_ID_HERE", "/dns6/$SERVER_IP/ws/tcp/9003"]
P2P_ANNOUNCE_PRIVATE=
P2P_pubsubPeerDiscoveryInterval=
P2P_dhtMaxInboundStreams=
P2P_dhtMaxOutboundStreams=
P2P_mDNSInterval=
P2P_connectionsMaxParallelDials=
P2P_connectionsDialTimeout=
P2P_ENABLE_UPNP=
P2P_ENABLE_AUTONAT=
P2P_ENABLE_CIRCUIT_RELAY_SERVER=
P2P_ENABLE_CIRCUIT_RELAY_CLIENT=
P2P_BOOTSTRAP_NODES=
P2P_FILTER_ANNOUNCED_ADDRESSES=
EOF

echo ".env file is created and populated."

# Starting a node
docker run --env-file .env -e 'getP2pNetworkStats' -p 8000:8000 -p 9000:9000 -p 9001:9001 -p 9002:9002 -p 9003:9003  ocean-node:mybuild

echo "Please wait 5-10 minutes for the node to start up. Check the status on the Ocean Node control panel."
echo "2nd part of instruction u can find here https://github.com/g7AzaZLO/ocean_protocol_auto_installer/tree/main"
