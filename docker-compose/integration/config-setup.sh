#!/bin/bash

sed -i "s|external_url .*|external_url 'https://$(hostname)'|g" /etc/unifiedpush/unifiedpush.rb
sed -i "s/# unifiedpush_server\['oauth2_subdomain_seperator'\] = \".\"/unifiedpush_server\['oauth2_subdomain_seperator'\] = \"-\"/g" /etc/unifiedpush/unifiedpush.rb
