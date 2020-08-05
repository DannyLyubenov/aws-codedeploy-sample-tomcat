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

set_ssm_param(){
  local ssm_param="$1"
  local git_commit="$2"

  aws ssm put-parameter --name "${ssm_param}" --value "${git_commit}" --type String --overwrite
}

main(){
  local ssm_param=""
  local git_commit=""

  ssm_param=$(printenv TEST_COMMIT)

  git_commit="commit${RANDOM:0:5}"
  set_ssm_param "${ssm_param}" "${git_commit}"
}

main