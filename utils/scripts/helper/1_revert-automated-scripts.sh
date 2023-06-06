#!/bin/bash

cd "$WORKING_DIR" || {
  echo "Error moving to the application's root directory."
  exit 1
}

cat "$WORKING_DIR"/utils/templates/copilot/api/manifest.yml           > "$WORKING_DIR"/copilot/api/manifest.yml
cat "$WORKING_DIR"/utils/templates/copilot/env/manifest.yml           > "$WORKING_DIR"/copilot/environments/"$AWS_WORKLOADS_ENV"/manifest.yml
cat "$WORKING_DIR"/utils/templates/iam/s3-alb-access-logs-policy.json > "$WORKING_DIR"/utils/aws/iam/s3-alb-access-logs-policy.json

cat "$WORKING_DIR"/utils/templates/envoy/envoy.yaml                   > "$WORKING_DIR"/utils/docker/envoy/envoy.yaml
cat "$WORKING_DIR"/utils/templates/envoy/certs/v3.ext                 > "$WORKING_DIR"/utils/docker/envoy/certs/v3.ext
