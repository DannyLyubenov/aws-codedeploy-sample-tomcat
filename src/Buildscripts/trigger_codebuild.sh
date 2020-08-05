#!/bin/bash
set -u
#
#  ECHOBOX CONFIDENTIAL
#
#  All Rights Reserved.
#
#  NOTICE: All information contained herein is, and remains the property of
#  Echobox Ltd. and itscheck_environment_selection suppliers, if any. The
#  intellectual and technical concepts contained herein are proprietary to
#  Echobox Ltd. and its suppliers and may be covered by Patents, patents in
#  process, and are protected by trade secret or copyright law. Dissemination
#  of this information or reproduction of this material, in any format, is
#  strictly forbidden unless prior written permission is obtained
#  from Echobox Ltd.
#
# Script will build html file about the chart packages created
# This will be appended to the send email if exists

#######################################
# Delete file if exists
# Globals:
# Arguments:
#  * par 1 : file to delete
# Returns:
#   None
#######################################
delete_file() {
  if [ -f "$1" ]; then
    rm "$1"
  fi
}

stop_running_builds(){
  local codebuild_name="$1"
  local log_file="codebuild_id.txt"
  local codebuild_id=""
  local codebuild_status=""

  aws codebuild list-builds-for-project \
      --project-name "${codebuild_name}" \
      --o text > "${log_file}"

  while IFS= read -r line; do
    codebuild_id=$(echo "${line}" | awk -F ' ' '{print $2}')
    codebuild_status=$(aws codebuild batch-get-builds --ids "${codebuild_id}" --query "builds[].buildStatus" --o text)

    if [ "${codebuild_status}" = "IN_PROGRESS" ]; then
      aws codebuild stop-build --id "${codebuild_id}"
      echo "Stopping: ${codebuild_id}"
    fi
  done < "${log_file}"

  delete_file "${log_file}"
}

start_codebuild(){
  local codebuild_name="$1"
  aws codebuild start-build --project-name "${codebuild_name}"
  
  echo "Starting Codebuild Project: ${codebuild_name}"
}

main(){
  local codebuild_name=""

  codebuild_name=$(printenv POST_CHECKS)

  stop_running_builds "${codebuild_name}"
  start_codebuild "${codebuild_name}"
}

main