#!/bin/bash

get_full_path() {
    # Absolute path to this script, e.g. /home/user/bin/foo.sh
    SCRIPT=$(readlink -f $0)

    if [ ! -d ${SCRIPT} ]; then
        # Absolute path this script is in, thus /home/user/bin
        SCRIPT=`dirname $SCRIPT`
    fi

    ( cd "${SCRIPT}" ; pwd )
}

SCRIPT_PATH="$(get_full_path ./)"

main(){
  # Download selected version
  curl --ssl -u "cb4:Cb4P@ssw0rd" -O ftp://us-ftp.c-b4.com/ups/unifiedpush-server-${UPS_VERSION}.el7.x86_64.rpm
  curl --ssl -u "cb4:Cb4P@ssw0rd" -O ftp://us-ftp.c-b4.com/ups/keycloak-server-${KC_VERSION}.el7.x86_64.rpm

  # Install version 
  rpm -i unifiedpush-server*.rpm
  rpm -i keycloak-server*.rpm

  # Setup default configuration
  sed -i "s|external_url .*|external_url 'https://$(hostname)'|g" /etc/unifiedpush/unifiedpush.rb
  sed -i "s/# unifiedpush_server\['oauth2_subdomain_seperator'\] = \".\"/unifiedpush_server\['oauth2_subdomain_seperator'\] = \"-\"/g" /etc/unifiedpush/unifiedpush.rb

  # Install cb4 theme
  git clone "https://cb4jenkins:${THEME_PASS}@bitbucket.org/C-B4/c-login-theme-dist"

  # Generate certificate using lets encrypt
  yum install certbot-release
}

# Defaults
UPS_VERSION=1.2.8-Final.1
KC_VERSION=1.2.8-Final.1

while [ -n "$1" ]; do
    v="${1#*=}"
    case "$1" in
        --ups-version=*)
            export UPS_VERSION="${v}"
            ;;
        --kc-version=*)
            export KC_VERSION="${v}"
            ;;
	--theme-password=*)
            export THEME_PASS="${v}"
            ;;
        --debug)
            DEBUG=1
            print_debug "Debug is ON..."
            ;;
        --help|*)
            cat <<__EOF__
Usage: $0
        --ups-version=version  - UPS version to use
        --kc-version=version   - KC version to use
        --debug                - prints debug statement when such are available in the script
__EOF__
        exit 1
    esac
    shift
done

trap revert 1
umask 0022
main
exit 0
