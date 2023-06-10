#!/bin/bash

cd "$WORKING_DIR" || {
  echo "Error moving to the application's root directory."
  exit 1
}
CERTS_DIR="$WORKING_DIR"/utils/certs

### VERIFYING CSR CERTIFICATE FILES
if [ ! -f "$CERTS_DIR"/ca-cert.pem ] || [ ! -f "$CERTS_DIR"/"$AWS_WORKLOADS_ENV"/server-key.pem ] || [ ! -f "$CERTS_DIR"/"$AWS_WORKLOADS_ENV"/server-cert-"$AWS_WORKLOADS_ENV".pem ]; then
  echo ""
  echo "Error: Not TLS certificates was found for the '$AWS_WORKLOADS_ENV' environment."
  echo "You can create <TLS Certificates> using the 'Helper Menu', option 3."
  exit 1
fi

### READING SERVER DOMAIN NAME AND SERVER FQDN
read -r -p 'Enter the <Domain Name> used in your CSR certificate: ' server_domain_name
if [ -z "$server_domain_name" ]; then
  echo "Error: The <Domain Name> is required."
  exit 1
fi
server_fqdn="$AWS_WORKLOADS_ENV.$server_domain_name"

### REMOVING PREVIOUS CONFIGURATION FILES
sh "$WORKING_DIR"/utils/scripts/helper/1_revert-automated-scripts.sh

### UPDATE ENVOY CONFIGURATION FILE WITH SERVER FQDN
sed -i'.bak' -e "s/server_fqdn/$server_fqdn/g;" \
      "$WORKING_DIR"/utils/docker/envoy/envoy-https-http.yaml
rm -f "$WORKING_DIR"/utils/docker/envoy/envoy-https-http.yaml.bak

echo ""
echo "Getting information from AWS. Please wait..."

### GETTING COGNITO USER POOL ID
cognito_user_pool_id=$(aws cognito-idp list-user-pools --max-results 1 --output text  \
  --query "UserPools[?contains(Name, 'CityUserPool')].[Id]"                           \
  --profile "$AWS_IDP_PROFILE")
if [ -z "$cognito_user_pool_id" ]; then
  echo ""
  echo "Error: Not Cognito User Pool ID was found with name: 'CityUserPool'."
  exit 0
fi

### ASKING TO PRUNE DOCKER SYSTEM
read -r -p "Do you want to prune your docker system? [y/N] " response
case $response in
  [yY])
    echo ""
    echo "Pruning docker system..."
    sh "$WORKING_DIR"/utils/scripts/helper/2_docker-system-prune.sh
    echo ""
    echo "Done!"
    ;;
  *)
    echo "Skipping..."
    ;;
esac

### UPDATING DOCKER COMPOSE ENVIRONMENT FILE
idp_aws_region=$(aws configure get region --profile "$AWS_IDP_PROFILE")
sed -i'.bak' -e "s/idp_aws_region/$idp_aws_region/g; s/cognito_user_pool_id/$cognito_user_pool_id/g"  \
      "$WORKING_DIR"/utils/docker/compose/tasks-api-dev.env
rm -f "$WORKING_DIR"/utils/docker/compose/tasks-api-dev.env.bak

### STARTING DOCKER CLUSTER
echo ""
echo "Starting Docker cluster..."
docker compose up --build
