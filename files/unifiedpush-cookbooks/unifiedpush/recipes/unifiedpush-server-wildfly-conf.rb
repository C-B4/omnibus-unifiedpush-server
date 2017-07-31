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

# Default location of install-dir is /opt/unifiedpush/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['unifiedpush-server']['dir']
modules_dir = "#{server_dir}/modules/org/postgresql/main"
cli_dir = "#{server_dir}/cli"

account_helper = AccountHelper.new(node)
unifiedpush_user = account_helper.unifiedpush_user

# These directories do not need to be writable for unifiedpush-server
[
  modules_dir,
  cli_dir
].each do |dir_name|
  directory dir_name do
    owner unifiedpush_user
    group "root"
    mode 0775
    recursive true
  end
end

unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash
keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash
 
# Prepare datasource cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-ds.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "unifiedpush-server-wildfly-ds-cli.erb"
  variables(unifiedpush_vars)
end

# Prepare http cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-http.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "unifiedpush-server-wildfly-http-cli.erb"
  variables(unifiedpush_vars)
end

# Prepare kc cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-kc.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "unifiedpush-server-wildfly-kc-cli.erb"
  variables(keycloak_vars)
end

# Prepare oauth2 cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-oauth2.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "unifiedpush-server-wildfly-oauth2-cli.erb"
  variables(unifiedpush_vars)
end

# Prepare jgroup cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-jgroup.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "unifiedpush-server-wildfly-jgroup-cli.erb"
  variables(unifiedpush_vars)
end

# Copy JMS configuration cli script.
remote_file "Copy jms cli script" do
  path "#{server_dir}/cli/unifiedpush-server-wildfly-jms.cli"
  source "file://#{install_dir}/embedded/apps/unifiedpush-server/configuration/jms-setup-wildfly.cli"
  owner unifiedpush_user
  group 'root'
  mode 0755
end

# Update configuration 
template "#{server_dir}/bin/standalone.conf" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "wildfly-standalone.conf.erb"
  variables(unifiedpush_vars)
end

# Configure postgresql drived for wildfly
include_recipe "unifiedpush::postgresql-module-wildfly-conf"

# Execute cli scripts
execute 'UPS datasource cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-ds.cli"
end

execute 'UPS http/s cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-http.cli"
end

execute 'UPS kc cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-kc.cli"
end

execute 'UPS oauth2 cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-oauth2.cli"
end

execute 'UPS jms cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-jms.cli"
end

execute 'UPS jgroup cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/unifiedpush-server-wildfly-jgroup.cli"
end

# Link apps
link "#{server_dir}/standalone/deployments/unifiedpush-server.war" do
  to "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server.war"
end
