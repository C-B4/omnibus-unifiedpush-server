#
# Copyright:: Copyright (c) 2017
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

# Define apache cassandra cookbook attributes.
CassandraHelper.new(node)

installation_dir = node['unifiedpush']['cassandra']['installation_dir']
# log_dir used in cassandra-chef-cookbook, log_directory used in logrotate recipe.
log_dir = node['unifiedpush']['cassandra']['log_dir']
log_directory = node['unifiedpush']['cassandra']['log_directory']
cassandra_user = node['unifiedpush']['cassandra']['user']

# Install apache cassandra from external package
# Must be first in action, create cassandra user/group.
include_recipe 'cassandra-dse' if node['unifiedpush']['cassandra']['enable']

# Cassandra log additional files to CASSANDRA_HOME/logs/.
[
  log_directory
].each do |dir_name|
  directory dir_name do
    owner cassandra_user
    group 'root'
    mode '0775'
    recursive true
  end
end

# Link logrotate dir to cassandra logs 
link "#{log_directory}/logs" do
  to log_dir
end

runit_service "cassandra" do
  down node['unifiedpush']['cassandra']['ha']
  control ['d']
  options({
    :log_directory => "#{log_directory}"
  }.merge(params))
  log_options node['unifiedpush']['logging'].to_hash.merge(node['unifiedpush']['cassandra'].to_hash)
end

# Make sure cassandra execution in not bloked by selinux
# This is required only because installation_dir is symbolic link.
execute "restorecon-cassandra-slink" do
  command "restorecon -Rv #{node['unifiedpush']['cassandra']['installation_dir']}"
  action :run
end

# NOTE: These recipes are written idempotently, but require a running
# Cassandra service.  They should run each time (on the appropriate
# backend machine, of course), because they also handle schema
# upgrades for new releases of Aerogear.  As a result, we can't
# just do a check against node['unifiedpush']['bootstrap']['enable'],
# which would only run them one time.
if node['unifiedpush']['cassandra']['enable']
  execute "/opt/unifiedpush/bin/unifiedpush-ctl start cassandra" do
    retries 20
  end

  ruby_block "wait for cassandra to start" do
    block do
      connectable = false
      12.times do |i|
        # Note that we have to include the port even for a local pipe, because the port number
        # is included in the pipe default.
        mode = `#{installation_dir}/bin/nodetool netstats`
        if !mode.include? "NORMAL"
          Chef::Log.fatal("Could not connect to local cassandra node, retrying in 10 seconds.")
          sleep 10
        else
          if i > 0
            Chef::Log.fatal("Cassandra netstats return NORMAL status, waiting additional 15 seconds.")
            sleep 15
          end
          connectable = true
          break
        end
      end

      unless connectable
        Chef::Log.fatal <<-ERR
Could not connect to the cassandra database.
Please check /var/log/unifiedpush/cassandra/current for more information.
ERR
        exit!(1)
      end
    end
  end

  include_recipe 'unifiedpush::cassandra_keyspace' if node['unifiedpush']['cassandra']['enable']
  include_recipe 'unifiedpush::cassandra_maintenance' if node['unifiedpush']['cassandra']['enable']
end
