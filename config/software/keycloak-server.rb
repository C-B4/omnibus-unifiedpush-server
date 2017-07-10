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

name "keycloak-server"
default_version "2.5.5.Final"

dependency "ruby"
dependency "bundler"
dependency "rsync"
dependency "unifiedpush-server"

version "2.5.5.Final" do
  source md5: "e580232fb2a1c7c9d4c89b6fef6a029d"
end

version "2.4.0.Final" do
  source md5: "12d2c1eedd7cdd60c7edb0e38bdc4f5a"
end

version "2.3.0.Final" do
  source md5: "32e46a61d38f20b6d72d493336ffb34e"
end

source url: "https://downloads.jboss.org/keycloak/#{version}/keycloak-overlay-#{version}.tar.gz"

build do
  command "mkdir -p #{install_dir}/embedded/apps/keycloak-server/keycloak-overlay-#{version}"
  sync "#{project_dir}/", "#{install_dir}/embedded/apps/keycloak-server/keycloak-overlay-#{version}"

  # Strip KC version from packages.
  link "#{install_dir}/embedded/apps/keycloak-server/keycloak-overlay-#{version}", "#{install_dir}/embedded/apps/keycloak-server/keycloak-overlay"
  link "#{install_dir}/embedded/apps/keycloak-server/keycloak-overlay/modules/system/add-ons/keycloak/org/keycloak/keycloak-wildfly-server-subsystem/main/keycloak-wildfly-server-subsystem-#{version}.jar #{install_dir}/embedded/apps/keycloak-server/keycloak-overlay/modules/system/add-ons/keycloak/org/keycloak/keycloak-wildfly-server-subsystem/main/keycloak-wildfly-server-subsystem.jar"
end
