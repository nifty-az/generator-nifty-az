#!/bin/bash

set -euo pipefail # exit on error, undefined variable, and error in pipeline
[ -n "${DEBUG:-}" ] && set -x # enable debug mode if DEBUG is set

<% if (hookLogging) { -%>
echo -e "  🪝 \033[32mRunning <%- hook %>...\033[0m"

<% } -%>
# Insert your code here

# AZD environment variables are available as shell environment variables:
#
# echo -e "  \033[32mAZD_ENVIRONMENT_NAME: ${AZD_ENVIRONMENT_NAME}\033[0m"
#
# Here are some other examples of what you can do in hook scripts:
#
<%- include(`${hook}.ejs`) %>

<% if (hookLogging) { -%>
echo -e "  🪝 \033[32mFinished <%- hook %>.\033[0m"
echo

<% } -%>
# Everything is fine, exit with 0
exit 0
