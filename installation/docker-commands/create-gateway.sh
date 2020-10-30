#!/bin/bash
# init

echo
echo
echo "===============  CREATE A NEW GATEWAY INSTANCE ==============="
echo
echo
echo "ℹ️  Press [ENTER] for default values:"
echo

echo
read -p "   Enter Gateway version you want to use [latest/development] (default = \"latest\") >>> " GATEWAY_TAG
if [ "$GATEWAY_TAG" == "" ]
then
  GATEWAY_TAG="latest"
fi

# Ask the user for the name of the new Gateway instance
read -p "   Enter a name for your new Gateway instance (default = \"gateway-instance\") >>> " GATEWAY_INSTANCE_NAME
if [ "$GATEWAY_INSTANCE_NAME" == "" ]
then
  GATEWAY_INSTANCE_NAME="gateway-instance"
fi

# Ask the user for the hummingobt data folder location
prompt_hummingbot_data_path () {
read -p "   Enter the full location path where your Hummingbot cert files are located  >>> " FOLDER
if [ "$FOLDER" == "" ]
then
  prompt_hummingbot_data_path
else
  if [ ! -d "$FOLDER" ]; then
    echo "‼️  Directory not found in ${FOLDER}"
    prompt_hummingbot_data_path
  fi
fi
}
prompt_hummingbot_data_path

# Ask the user for the ethereum rpc url
prompt_ethereum_rpc_url () {
read -p "   Enter the Ethereum RPC URL set in your Hummingbot instance  >>> " RPC_URL
if [ "$RPC_URL" == "" ]
then
  prompt_ethereum_rpc_url
fi
}
prompt_ethereum_rpc_url


# Ask the user for the hummingobt data folder location
prompt_password () {
read -s -p "   Enter the your Gateway cert passphrase configured in Hummingbot  >>> " PASSWORD
}
prompt_password

 # Check available open port for Gateway
 PORT=5000
 LIMIT=$((PORT+1000))
 while [[ $PORT -le LIMIT ]]
   do
     if [[ $(netstat -nat | grep "$PORT") ]]; then
       # check another port
       ((PORT = PORT + 1))
     else
       break
     fi
 done

echo
echo "ℹ️  Confirm below if the instance and its folders are correct:"
echo
printf "%30s %5s\n" "Gateway instance name:" "$GATEWAY_INSTANCE_NAME"
printf "%30s %5s\n" "Version:" "coinalpha/gateway-api:$GATEWAY_TAG"
echo
printf "%30s %5s\n" "Ethereum RPC URL:" "$RPC_URL"
printf "%30s %5s\n" "Gateway cert path:" "$FOLDER"
printf "%30s %5s\n" "Gateway port:" "$PORT"
echo

prompt_proceed () {
 read -p "   Do you want to proceed? [Y/N] >>> " PROCEED
 if [ "$PROCEED" == "" ]
 then
 PROCEED="Y"
 fi
}

# Execute docker commands
create_instance () {
 echo
 echo "Creating Gateway instance ... "
 echo



 # 5) Launch a new instance of hummingbot
 docker run -d \
 --name $GATEWAY_INSTANCE_NAME \
 -p 127.0.0.1:$PORT:5000 \
 -e CERT_PASSPHRASE="$PASSWORD" \
 -e BALANCER_NETWORK="mainnet" \
 -e ETHEREUM_RPC_URL="$RPC_URL" \
 -e SUBGRAPH_URL="https://api.thegraph.com/subgraphs/name/balancer-labs/balancer" \
 --mount "type=bind,source=$FOLDER,destination=/usr/src/app/certs/" \
 coinalpha/gateway-api:$GATEWAY_TAG
}

prompt_proceed
if [[ "$PROCEED" == "Y" || "$PROCEED" == "y" ]]
then
 create_instance
else
 echo "   Aborted"
 echo
fi