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

account_helper = AccountHelper.new(node)
unifiedpush_user = account_helper.unifiedpush_user

keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash
unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash

include_recipe "unifiedpush::postgresql-module-wildfly-conf"

execute "copy keycloak overlay to wildfly dir" do
    command "cp -R #{install_dir}/embedded/apps/keycloak-server/keycloak-overlay/* #{server_dir}"
    user "root"
end

template "#{server_dir}/cli/keycloak-server-wildfly.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "keycloak-server-wildfly-cli.erb"
  variables(unifiedpush_vars.merge(keycloak_vars).merge({
      :server_dir => "#{server_dir}"
    }
  ))
end

template "#{server_dir}/cli/keycloak-server-ups-realms.cli" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "keycloak-server-ups-realms-cli.erb"
  variables({:server_dir => "#{server_dir}"})
end

execute 'KC datasource and config cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/keycloak-server-wildfly.cli"
end

execute 'KC datasource and config cli script' do
  command "#{server_dir}/bin/jboss-cli.sh --file=#{server_dir}/cli/keycloak-server-ups-realms.cli"
end

# Extract default theme
execute 'extract_ups_theme' do
  command "tar xzvf #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-keycloak-theme.tar.gz"
  cwd "#{server_dir}/themes"
end

