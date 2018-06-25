#
# Copyright:: Copyright (c) 2015.
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

account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

install_dir = node['package']['install-dir']
nginx_dir = node['unifiedpush']['nginx']['dir']
nginx_conf_dir = File.join(nginx_dir, "conf")
nginx_confd_dir = File.join(nginx_dir, "conf.d")
nginx_html_dir = File.join(nginx_dir, "www/html")
nginx_ups_html_dir = File.join(nginx_html_dir, "unifiedpush-server")
nginx_log_dir = node['unifiedpush']['nginx']['log_directory']

# These directories do not need to be writable for unifiedpush-server
[
  nginx_dir,
  nginx_conf_dir,
  nginx_confd_dir,
  nginx_html_dir,
  nginx_ups_html_dir,
  nginx_log_dir,
].each do |dir_name|
  directory dir_name do
    owner account_helper.web_server_user
    group 'root'
    mode '0750'
    recursive true
  end
end

link File.join(nginx_dir, "logs") do
  to nginx_log_dir
end

# Link logrotate dir to self.
# A workarround to ensure logrotate always exists at log_directory/logs
link "#{nginx_log_dir}/logs" do
  to nginx_log_dir
end

nginx_config = File.join(nginx_conf_dir, "nginx.conf")
nginx_locations = File.join(nginx_conf_dir, "locations.import")

unifiedpush_server_http_conf = File.join(nginx_conf_dir, "unifiedpush-http.conf")

# If the service is enabled, check if we are using internal nginx
unifiedpush_server_enabled = node['unifiedpush']['nginx']['enable']

# Include the config file for unifiedpush-server in nginx.conf later
nginx_vars = node['unifiedpush']['nginx'].to_hash.merge({
               :unifiedpush_http_config => unifiedpush_server_enabled ? unifiedpush_server_http_conf : nil,
               :unifiedpush_http_configd => nginx_confd_dir
             })

if nginx_vars['listen_https'].nil?
  nginx_vars['https'] = node['unifiedpush']['unifiedpush-server']['server_https']
else
  nginx_vars['https'] = nginx_vars['server_https']
end

template unifiedpush_server_http_conf do
  source "nginx-unifiedpush-http.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(nginx_vars.merge(
    {
      :fqdn => node['unifiedpush']['unifiedpush-server']['server_host'],
      :html_dir => nginx_html_dir
    }
  ))
  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")
  action unifiedpush_server_enabled ? :create : :delete
end

template nginx_config do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables nginx_vars
  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")
end

template nginx_locations do
  source "locations.import.erb"
  owner "root"
  group "root"
  mode "0644"
  variables nginx_vars
  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")
end

# Extract ups static contect to html directory
if node['unifiedpush']['unifiedpush-server']['enable']
  execute 'extract_ups_static_content' do
    command "tar xzvf #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui.tar.gz"
    cwd "#{nginx_ups_html_dir}"
  end
end

# Make sure owner is unifiedpush_user
execute "chown-nginx-resources" do
  command "chown -R #{account_helper.web_server_user}:root #{nginx_ups_html_dir}"
  action :run
end

runit_service "nginx" do
  down node['unifiedpush']['nginx']['ha']
  options({
    :log_directory => nginx_log_dir
  }.merge(params))
  log_options node['unifiedpush']['logging'].to_hash.merge(node['unifiedpush']['nginx'].to_hash)
end

if node['unifiedpush']['bootstrap']['enable']
  execute "/opt/unifiedpush/bin/unifiedpush-ctl start nginx" do
    retries 20
  end
end
