#!/bin/bash

cd "$WORKING_DIR"/utils/certs/"$AWS_WORKLOADS_ENV" || {
  echo "Error moving to the '$AWS_WORKLOADS_ENV' Certification's directory."
  exit 1
}
CERTS_DIR="$WORKING_DIR"/utils/certs

### VERIFYING CSR CERTIFICATE FILES
if [ ! -f "$CERTS_DIR"/ca-cert.pem ] || [ ! -f ./server-key.pem ] || [ ! -f ./server-cert-"$AWS_WORKLOADS_ENV".pem ]; then
  echo ""
  echo "Error: Not TLS certificates was found for the '$AWS_WORKLOADS_ENV' environment."
  echo "You can create <TLS Certificates> using the 'Helper Menu', option 3."
  exit 1
fi

echo ""
echo "IMPORTING CSR CERTIFICATE WITH CERTIFICATE CHAIN..."
aws acm import-certificate                                  \
  --private-key         fileb://server-key.pem              \
  --certificate-chain   fileb://"$CERTS_DIR"/ca-cert.pem    \
  --certificate         fileb://server-cert-"$AWS_WORKLOADS_ENV".pem  \
  --profile             "$AWS_WORKLOADS_PROFILE"
echo "DONE!"
