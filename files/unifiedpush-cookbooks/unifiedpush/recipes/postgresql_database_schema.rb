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

install_dir = node['package']['install-dir']
database_name = node['unifiedpush']['unifiedpush-server']['db_database']

account_helper = AccountHelper.new(node)
unifiedpush_user = account_helper.unifiedpush_user

template "/tmp/db.properties" do
  source "unifiedpush-server-db-properties.erb"
  owner unifiedpush_user
  mode "0644"
  variables(node['unifiedpush']['unifiedpush-server'].to_hash)
end

execute "initialize unifiedpush-server database" do
  cwd "#{install_dir}/embedded/apps/unifiedpush-server/initdb/bin"
  command "./init-unifiedpush-db.sh --database=#{database_name} --config-path=/tmp/db.properties"
  action :nothing
end
