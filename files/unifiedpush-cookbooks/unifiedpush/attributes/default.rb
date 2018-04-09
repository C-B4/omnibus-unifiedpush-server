#
# Copyright:: Copyright (c) 2015
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

####
# omnibus options
####
default['unifiedpush']['bootstrap']['enable'] = true
# create users and groups needed for the package
default['unifiedpush']['manage-accounts']['enable'] = true
# Default contactpoints for symmetric cluster mode.
# Override spesific properties [cas_contactpoints, server_contactpoints, seeds] unless spesified to unifiedpush.rb
default['unifiedpush']['global']['contactpoints'] = node['fqdn']
default['unifiedpush']['global']['backup_path'] = "/var/opt/unifiedpush/backups"

####
## The Unifiedpush User that services run as
####
# The Unifiedpush User that services run as
default['unifiedpush']['user']['username'] = "unifiedpush"
default['unifiedpush']['user']['group'] = "unifiedpush"
default['unifiedpush']['user']['uid'] = nil
default['unifiedpush']['user']['gid'] = nil
# The shell for the unifiedpush services user
default['unifiedpush']['user']['shell'] = "/bin/sh"
# The home directory for the unifiedpush services user
default['unifiedpush']['user']['home'] = "/var/opt/unifiedpush"

####
# Java installation options, this package is not embeded.
# When enabled, external java package will be installed.
####
default['unifiedpush']['java']['install_java'] = false
default['unifiedpush']['java']['jdk_version'] = '8'
default['unifiedpush']['java']['install_flavor'] = 'openjdk'
default['unifiedpush']['java']['set_default'] = true
default['unifiedpush']['java']['oracle']['accept_oracle_download_terms'] = true

####
# Unifiedpush Server app
####
default['unifiedpush']['unifiedpush-server']['enable'] = true
default['unifiedpush']['unifiedpush-server']['ha'] = false
default['unifiedpush']['unifiedpush-server']['dir'] = "/var/opt/unifiedpush/unifiedpush-server"
default['unifiedpush']['unifiedpush-server']['log_directory'] = "/var/log/unifiedpush/unifiedpush-server"
default['unifiedpush']['unifiedpush-server']['environment'] = 'production'
default['unifiedpush']['unifiedpush-server']['env'] = {
  'SIDEKIQ_MEMORY_KILLER_MAX_RSS' => '1000000',
  # PATH to set on the environment
  # defaults to /opt/unifiedpush/embedded/bin:/bin:/usr/bin. The install-dir path is set at build time
  'PATH' => "#{node['package']['install-dir']}/bin:#{node['package']['install-dir']}/embedded/bin:/bin:/usr/bin"
}
default['unifiedpush']['unifiedpush-server']['documents_directory'] = "/var/opt/unifiedpush/unifiedpush-server/documents"
default['unifiedpush']['unifiedpush-server']['uploads_directory'] = "/var/opt/unifiedpush/unifiedpush-server/uploads"
default['unifiedpush']['unifiedpush-server']['server_host'] = node['fqdn']
default['unifiedpush']['unifiedpush-server']['server_address'] = node['ipaddress']
default['unifiedpush']['unifiedpush-server']['server_contactpoints'] = node['fqdn']
default['unifiedpush']['unifiedpush-server']['server_port'] = 80
default['unifiedpush']['unifiedpush-server']['server_https'] = false
default['unifiedpush']['unifiedpush-server']['time_zone'] = nil
default['unifiedpush']['unifiedpush-server']['cache_owners'] = 1
default['unifiedpush']['unifiedpush-server']['java_xmx'] = "1g"
# OAuth2 Configureation, webapp_host is used as web applications root-url.
default['unifiedpush']['unifiedpush-server']['webapp_host'] = node['fqdn']
default['unifiedpush']['unifiedpush-server']['oauth2_enabled'] = true
default['unifiedpush']['unifiedpush-server']['oauth2_admin_user'] = "admin"
default['unifiedpush']['unifiedpush-server']['oauth2_admin_pass'] = "password"
default['unifiedpush']['unifiedpush-server']['oauth2_subdomain_seperator'] = "."
# Cassandra connection params
default['unifiedpush']['unifiedpush-server']['cas_contactpoints'] = node['fqdn']
default['unifiedpush']['unifiedpush-server']['cas_port'] = "9042"
default['unifiedpush']['unifiedpush-server']['cas_keyspace'] = "unifiedpush_server"
default['unifiedpush']['unifiedpush-server']['cas_consistencylevel'] = "QUORUM"
# PostgreSQL connection params
default['unifiedpush']['unifiedpush-server']['db_adapter'] = "postgresql"
default['unifiedpush']['unifiedpush-server']['db_encoding'] = "unicode"
default['unifiedpush']['unifiedpush-server']['db_database'] = "unifiedpush_server"
default['unifiedpush']['unifiedpush-server']['db_pool'] = 10
# db_username, db_host, db_port oveeride PostgreSQL properties [sql_user, listen_address, port]
default['unifiedpush']['unifiedpush-server']['db_username'] = "aerobase_server"
default['unifiedpush']['unifiedpush-server']['db_password'] = nil
# Postgresql host over TCP connection, java jdbc does not support unix socket.
default['unifiedpush']['unifiedpush-server']['db_host'] = "localhost"
default['unifiedpush']['unifiedpush-server']['db_port'] = 5432
default['unifiedpush']['unifiedpush-server']['db_socket'] = nil
default['unifiedpush']['unifiedpush-server']['db_sslmode'] = nil
default['unifiedpush']['unifiedpush-server']['db_sslrootcert'] = nil
# OTP verification params
default['unifiedpush']['unifiedpush-server']['inst_verification'] = false
default['unifiedpush']['unifiedpush-server']['inst_verification_class'] = "org.jboss.aerogear.unifiedpush.service.sms.ClickatellSMSSender"
default['unifiedpush']['unifiedpush-server']['inst_verification_master_code'] = nil
default['unifiedpush']['unifiedpush-server']['inst_verification_properties'] = []
# Example - Additinal properties will be passed into verification class`
# ['aerogear.config.sms.sender.clickatell.api_id=','aerogear.config.sms.sender.clickatell.username=','aerogear.config.sms.sender.clickatell.password=','aerogear.config.sms.sender.clickatell.encoding=UTF-8','aerogear.config.sms.sender.clickatell.template={0}']

####
# Keycloak Server app
####
default['unifiedpush']['keycloak-server']['enable'] = true
default['unifiedpush']['keycloak-server']['ha'] = false
# When keycloak-server is disabled, server_host should point to external URL.
default['unifiedpush']['keycloak-server']['server_host'] = node['fqdn']
default['unifiedpush']['keycloak-server']['server_https'] = false
default['unifiedpush']['keycloak-server']['context_root'] = "auth"

default['unifiedpush']['keycloak-server']['db_username'] = "keycloak_server"
default['unifiedpush']['keycloak-server']['db_database'] = "keycloak_server"
default['unifiedpush']['keycloak-server']['db_minpoll_size'] = "5"
default['unifiedpush']['keycloak-server']['db_maxpoll_size'] = "15"

###
# PostgreSQL
###
default['unifiedpush']['postgresql']['enable'] = true
default['unifiedpush']['postgresql']['ha'] = false
default['unifiedpush']['postgresql']['dir'] = "/var/opt/unifiedpush/postgresql"
default['unifiedpush']['postgresql']['data_dir'] = "/var/opt/unifiedpush/postgresql/data"
default['unifiedpush']['postgresql']['log_directory'] = "/var/log/unifiedpush/postgresql"
default['unifiedpush']['postgresql']['unix_socket_directory'] = "/var/opt/unifiedpush/postgresql"
default['unifiedpush']['postgresql']['username'] = "unifiedpush-sql"
default['unifiedpush']['postgresql']['uid'] = nil
default['unifiedpush']['postgresql']['gid'] = nil
default['unifiedpush']['postgresql']['shell'] = "/bin/sh"
default['unifiedpush']['postgresql']['home'] = "/var/opt/unifiedpush/postgresql"
# Postgres User's Environment Path
# defaults to /opt/unifiedpush/embedded/bin:/opt/unifiedpush/bin/$PATH. The install-dir path is set at build time
default['unifiedpush']['postgresql']['user_path'] = "#{node['package']['install-dir']}/embedded/bin:#{node['package']['install-dir']}/bin:$PATH"
default['unifiedpush']['postgresql']['bin_dir'] = "#{node['package']['install-dir']}/embedded/bin"
default['unifiedpush']['postgresql']['sql_user'] = "aerobase_server"
default['unifiedpush']['postgresql']['port'] = 5432
default['unifiedpush']['postgresql']['listen_address'] = 'localhost'
default['unifiedpush']['postgresql']['max_connections'] = 200
default['unifiedpush']['postgresql']['md5_auth_cidr_addresses'] = []
default['unifiedpush']['postgresql']['trust_auth_cidr_addresses'] = ['localhost']
default['unifiedpush']['postgresql']['shmmax'] = node['kernel']['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['unifiedpush']['postgresql']['shmall'] = node['kernel']['machine'] =~ /x86_64/ ? 4194304 : 1048575
default['unifiedpush']['postgresql']['semmsl'] = 250
default['unifiedpush']['postgresql']['semmns'] = 32000
default['unifiedpush']['postgresql']['semopm'] = 32
default['unifiedpush']['postgresql']['semmni'] = ((node['unifiedpush']['postgresql']['max_connections'].to_i / 16) + 250)

# Resolves CHEF-3889
if (node['memory']['total'].to_i / 4) > ((node['unifiedpush']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  default['unifiedpush']['postgresql']['shared_buffers'] = "14336MB"
else
  default['unifiedpush']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end

default['unifiedpush']['postgresql']['work_mem'] = "8MB"
default['unifiedpush']['postgresql']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
default['unifiedpush']['postgresql']['max_wal_size'] = "1GB"
default['unifiedpush']['postgresql']['checkpoint_timeout'] = "5min"
default['unifiedpush']['postgresql']['checkpoint_completion_target'] = 0.9
default['unifiedpush']['postgresql']['checkpoint_warning'] = "30s"

###
# Apache Cassandra
###
default['unifiedpush']['cassandra']['enable'] = true
default['unifiedpush']['cassandra']['schedule_repairs'] = false
default['unifiedpush']['cassandra']['ha'] = false
default['unifiedpush']['cassandra']['install_method'] = 'tarball'
default['unifiedpush']['cassandra']['version'] = '3.11.1'
default['unifiedpush']['cassandra']['user'] = 'unifiedpush-cas'
default['unifiedpush']['cassandra']['group'] = 'unifiedpush'
default['unifiedpush']['cassandra']['installation_dir'] = '/var/opt/unifiedpush/cassandra/cassandra'
# log_dir used in cassandra-chef-cookbook, log_directory used in logrotate recipe.
default['unifiedpush']['cassandra']['log_dir'] = '/var/opt/unifiedpush/cassandra/cassandra/logs'
default['unifiedpush']['cassandra']['log_directory'] = '/var/log/unifiedpush/cassandra'
default['unifiedpush']['cassandra']['root_dir'] = '/var/opt/unifiedpush/cassandra/data'
default['unifiedpush']['cassandra']['heap_dump_dir'] = '/var/opt/unifiedpush/cassandra/data'
default['unifiedpush']['cassandra']['install_java'] = false
default['unifiedpush']['cassandra']['use_systemd'] = false
default['unifiedpush']['cassandra']['use_initd'] = false
default['unifiedpush']['cassandra']['setup_jamm'] = true
default['unifiedpush']['cassandra']['seeds'] = node['fqdn']
default['unifiedpush']['cassandra']['max_heap_size'] = '1G'
default['unifiedpush']['cassandra']['heap_new_size'] = '200M'

# Cluster config options
default['unifiedpush']['cassandra-config']['cluster_name'] = 'unifiedpush-cluster'

####
# Web server
####
# Username for the webserver user
default['unifiedpush']['web-server']['username'] = 'unifiedpush-www'
default['unifiedpush']['web-server']['group'] = 'unifiedpush-www'
default['unifiedpush']['web-server']['uid'] = nil
default['unifiedpush']['web-server']['gid'] = nil
default['unifiedpush']['web-server']['shell'] = '/bin/false'
default['unifiedpush']['web-server']['home'] = '/var/opt/unifiedpush/nginx'
# When bundled nginx is disabled we need to add the external webserver user to the Unifiedpush webserver group
default['unifiedpush']['web-server']['external_users'] = []

####
#NGINX
####
default['unifiedpush']['nginx']['enable'] = true
default['unifiedpush']['nginx']['ha'] = false
default['unifiedpush']['nginx']['dir'] = "/var/opt/unifiedpush/nginx"
default['unifiedpush']['nginx']['log_directory'] = "/var/log/unifiedpush/nginx"
default['unifiedpush']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['unifiedpush']['nginx']['worker_connections'] = 10240
default['unifiedpush']['nginx']['sendfile'] = 'off'
default['unifiedpush']['nginx']['tcp_nopush'] = 'on'
default['unifiedpush']['nginx']['tcp_nodelay'] = 'on'
default['unifiedpush']['nginx']['proxy_buffer_size'] = '8k'
default['unifiedpush']['nginx']['proxy_buffers'] = '32 16k'
default['unifiedpush']['nginx']['proxy_busy_buffers_size'] = '32k'
default['unifiedpush']['nginx']['server_names_hash_bucket_size'] = "64"
default['unifiedpush']['nginx']['gzip'] = "on"
default['unifiedpush']['nginx']['gzip_http_version'] = "1.0"
default['unifiedpush']['nginx']['gzip_comp_level'] = "2"
default['unifiedpush']['nginx']['gzip_proxied'] = "any"
default['unifiedpush']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
default['unifiedpush']['nginx']['keepalive_timeout'] = 65
default['unifiedpush']['nginx']['client_max_body_size'] = '250m'
default['unifiedpush']['nginx']['cache_max_size'] = '5000m'
default['unifiedpush']['nginx']['redirect_http_to_https'] = false
default['unifiedpush']['nginx']['redirect_http_to_https_port'] = 80
default['unifiedpush']['nginx']['ssl_certificate'] = "/etc/unifiedpush/ssl/#{node['fqdn']}.crt"
default['unifiedpush']['nginx']['ssl_certificate_key'] = "/etc/unifiedpush/ssl/#{node['fqdn']}.key"
default['unifiedpush']['nginx']['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"
default['unifiedpush']['nginx']['ssl_prefer_server_ciphers'] = "on"
default['unifiedpush']['nginx']['ssl_protocols'] = "TLSv1 TLSv1.1 TLSv1.2" # recommended by https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
default['unifiedpush']['nginx']['ssl_session_cache'] = "builtin:1000  shared:SSL:10m" # recommended in http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['unifiedpush']['nginx']['ssl_session_timeout'] = "5m" # default according to http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['unifiedpush']['nginx']['ssl_dhparam'] = nil # Path to dhparam.pem
default['unifiedpush']['nginx']['listen_addresses'] = ['*']
default['unifiedpush']['nginx']['listen_port'] = nil # override only if you have a reverse proxy
default['unifiedpush']['nginx']['listen_https'] = nil # override only if your reverse proxy internally communicates over HTTP
default['unifiedpush']['nginx']['custom_unifiedpush_server_config'] = nil
default['unifiedpush']['nginx']['custom_nginx_config'] = nil

###
# Logging
###
default['unifiedpush']['logging']['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
default['unifiedpush']['logging']['svlogd_num'] = 30 # keep 30 rotated log files
default['unifiedpush']['logging']['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
default['unifiedpush']['logging']['svlogd_filter'] = "gzip" # compress logs with gzip
default['unifiedpush']['logging']['svlogd_udp'] = nil # transmit log messages via UDP
default['unifiedpush']['logging']['svlogd_prefix'] = nil # custom prefix for log messages
default['unifiedpush']['logging']['udp_log_shipping_host'] = nil # remote host to ship log messages to via UDP
default['unifiedpush']['logging']['udp_log_shipping_port'] = 514 # remote host to ship log messages to via UDP
default['unifiedpush']['logging']['logrotate_frequency'] = "daily" # rotate logs daily
default['unifiedpush']['logging']['logrotate_size'] = nil # do not rotate by size by default
default['unifiedpush']['logging']['logrotate_rotate'] = 30 # keep 30 rotated logs
default['unifiedpush']['logging']['logrotate_compress'] = "compress" # see 'man logrotate'
default['unifiedpush']['logging']['logrotate_method'] = "copytruncate" # see 'man logrotate'
default['unifiedpush']['logging']['logrotate_postrotate'] = nil # no postrotate command by default

###
# Logrotate
###
default['unifiedpush']['logrotate']['enable'] = true
default['unifiedpush']['logrotate']['ha'] = false
default['unifiedpush']['logrotate']['dir'] = "/var/opt/unifiedpush/logrotate"
default['unifiedpush']['logrotate']['log_directory'] = "/var/log/unifiedpush/logrotate"
default['unifiedpush']['logrotate']['services'] = %w{nginx unifiedpush-server cassandra}
default['unifiedpush']['logrotate']['pre_sleep'] = 600 # sleep 10 minutes before rotating after start-up
default['unifiedpush']['logrotate']['post_sleep'] = 3000 # wait 50 minutes after rotating
