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

account_helper = AccountHelper.new(node)
unifiedpush_user = account_helper.unifiedpush_user

# These directories do not need to be writable for unifiedpush-server
[
  modules_dir
].each do |dir_name|
  directory dir_name do
    owner unifiedpush_user
    group "root"
    mode 0775
    recursive true
  end
end

# Add postgres module
template "#{modules_dir}/module.xml" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "wildfly-postgres-module.xml.erb"
end

# Copy postgres JDBC driver
remote_file "Copy postgres driver file" do
  path "#{modules_dir}/postgresql-42.1.4.jar"
  source "file://#{install_dir}/embedded/apps/unifiedpush-server/initdb/lib/postgresql-42.1.4.jar"
  owner unifiedpush_user
  group 'root'
  mode 0755
end
