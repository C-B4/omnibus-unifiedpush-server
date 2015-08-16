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

require 'openssl'

# Default location of install-dir is /opt/gitlab/. This path is set during build time.
# DO NOT change this value unless you are building your own GitLab packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

directory "/etc/unifiedpush" do
  owner "root"
  group "root"
  mode "0775"
  action :nothing
end.run_action(:create)

Unifiedpush[:node] = node
if File.exists?("/etc/unifiedpush/unifiedpush.rb")
  Unifiedpush.from_file("/etc/unifiedpush/unifiedpush.rb")
end
node.consume_attributes(Unifiedpush.generate_config(node['fqdn']))

if File.exists?("/var/opt/unifiedpush/bootstrapped")
	node.set['gitlab']['bootstrap']['enable'] = false
end

directory "/var/opt/unifiedpushr" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "#{install_dir}/embedded/etc" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

if node['unifiedpush']['unifiedpush']['enable']
  include_recipe "unifiedpush::users"
  include_recipe "unifiedpush::unifiedpush"
end

include_recipe "unifiedpush::selinux"
include_recipe "unifiedpush::cron"

# Install our runit instance
include_recipe "runit"

# Configure Services
[
  "postgresql", # Postgresql depends on Redis because of `rake db:seed_fu`
  "nginx",
  "logrotate",
  "bootstrap",
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "unifiedpush::#{service}"
  else
    include_recipe "unifiedpush::#{service}_disable"
  end
end
