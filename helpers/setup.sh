#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

show_help() {
  cat <<EOF
Usage: ${0##*/} -p PROJECT_ID [-e] [-f HOST_PROJECT]
       ${0##*/} -h

Generate a service account with the IAM roles needed to run the Forseti Terraform module.

Options:

    -p PROJECT_ID    The project ID where Forseti resources will be created.
    -e               Add additional IAM roles for running the real time policy enforcer.
    -f HOST_PROJECT_ID  ID of a project holding shared vpc.

Examples:

    ${0##*/} -p forseti-235k -o 22592784945
    ${0##*/} -p forseti-enforcer-99e4 -o 22592784945 -e

EOF
}

PROJECT_ID=""
WITH_ENFORCER=""
HOST_PROJECT_ID=""

OPTIND=1
while getopts ":hep:f:o:" opt; do
  case "$opt" in
    h)
      show_help
      exit 0
      ;;
    e)
      WITH_ENFORCER=1
      ;;
    p)
      PROJECT_ID="$OPTARG"
      ;;
    f)
      HOST_PROJECT_ID="$OPTARG"
      ;;
    *)
      echo "Unhandled option: -$opt" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [[ -z "$PROJECT_ID" ]]; then
  echo "ERROR: PROJECT_ID must be set."
  show_help >&2
  exit 1
fi

# Ensure that we can fetch the IAM policy on the Forseti project.
if ! gcloud projects get-iam-policy "$PROJECT_ID" 2>&- 1>&-; then
  echo "ERROR: Unable to fetch IAM policy on project $PROJECT_ID."
  exit 1
fi

SERVICE_ACCOUNT_NAME="cloud-foundation-forseti-${RANDOM}"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
STAGING_DIR="${PWD}"
KEY_FILE="${STAGING_DIR}/credentials.json"

echo "Enabling services"
gcloud services enable \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    --project "${PROJECT_ID}"

gcloud iam service-accounts \
    --project "${PROJECT_ID}" create ${SERVICE_ACCOUNT_NAME} \
    --display-name "${SERVICE_ACCOUNT_NAME}"

echo "Downloading key to credentials.json..."

gcloud iam service-accounts keys create "${KEY_FILE}" \
    --iam-account "${SERVICE_ACCOUNT_EMAIL}" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.instanceAdmin" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.networkViewer" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.securityAdmin" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/iam.serviceAccountAdmin" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/serviceusage.serviceUsageAdmin" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/iam.serviceAccountUser" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.admin" \
    --user-output-enabled false

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/cloudsql.admin" \
    --user-output-enabled false

if [[ -n "$WITH_ENFORCER" ]]; then
  project_roles=("roles/pubsub.admin")

  echo "Granting real time policy enforcer roles on project $PROJECT_ID..."
  for project_role in "${project_roles[@]}"; do
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="$project_role" \
        --user-output-enabled false
  done
fi

if [[ $HOST_PROJECT_ID != "" ]];
then
    echo "Enabling services on host project"
    gcloud services enable \
        cloudresourcemanager.googleapis.com \
        compute.googleapis.com \
        serviceusage.googleapis.com \
        --project "${HOST_PROJECT_ID}"

    gcloud projects add-iam-policy-binding "${HOST_PROJECT_ID}" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/compute.securityAdmin" \
        --user-output-enabled false

    gcloud projects add-iam-policy-binding "${HOST_PROJECT_ID}" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/compute.networkAdmin" \
        --user-output-enabled false
fi
echo "All done."
