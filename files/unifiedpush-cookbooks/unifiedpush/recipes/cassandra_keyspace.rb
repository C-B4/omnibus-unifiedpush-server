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
keyspace_name = node['unifiedpush']['unifiedpush-server']['cas_keyspace']

omnibus_helper = OmnibusHelper.new(node)

execute "initialize cassandra keyspace" do
  cwd "#{install_dir}/embedded/apps/unifiedpush-server/initdb/bin"
  command "./init-cassandra-db.sh #{keyspace_name}"
  not_if { omnibus_helper.service_down?("cassandra") } 
end
