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

installation_dir = node['unifiedpush']['cassandra']['installation_dir']

cron 'cassandra-nodetool-nightly-repair' do
  minute "0"
  hour "1"
  user "root"
  command 'source ' + File.join('/etc/profile.d', node['cassandra']['service_name'] + '.sh') + "; #{installation_dir}/bin/nodetool repair > /tmp/nodetool-repair.log 2>&1"
end

cron 'cassandra-nodetool-full-repair' do
  minute "0"
  hour "2"
  day '1'
  user "root"
  command 'source ' + File.join('/etc/profile.d', node['cassandra']['service_name'] + '.sh') + "; #{installation_dir}/bin/nodetool repair --full > /tmp/nodetool-repair.log 2>&1"
end

