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

add_command 'reload', 'Run migrations after a package upgrade', 2 do |cmd_name, sv_name|
  service_statuses = `#{base_path}/bin/unifiedpush-ctl status`

  if /: runsv not running/.match(service_statuses) || service_statuses.empty? then
    log 'It looks like Unifiedpush has not been installed yet; skipping the upgrade '\
      'script.'
    exit! 0
  end

  case sv_name
  when 'nginx'
    # run_sv_command_for_service('reload', sv_name)
    output=system("#{base_path}/embedded/sbin/nginx -t -s -g \"pid /var/opt/unifiedpush/nginx/nginx.pid;\"")
  else
    puts "Usage: #{cmd_name} is supported only for nginx"
  end


  SERVICE_WAIT = 30
  status = -1
  SERVICE_WAIT.times do
    status = run_sv_command_for_service('status', sv_name)
    break if status.zero?
    sleep 1
  end
  abort "Failed to reload #{sv_name}" unless status.zero?
end
