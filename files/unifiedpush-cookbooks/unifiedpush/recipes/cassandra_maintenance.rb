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
cassandra_user = node['unifiedpush']['cassandra']['user']

# Due to CASSANDRA-9143, DataStax recommends switching to full repairs
# https://docs.datastax.com/en/cassandra/3.0/cassandra/tools/toolsRepair.html
# Start every Suterday at 10PM EST
cron 'cassandra-nodetool-weekly-full-repair' do
  minute "1"
  hour "3"
  weekday '1'
  user "#{cassandra_user}"
  command "#{installation_dir}/bin/nodetool repair --full -pr -seq --trace > /tmp/nodetool-repair.log 2>&1"
  not_if { !node['unifiedpush']['cassandra']['schedule_repairs'] }
end
