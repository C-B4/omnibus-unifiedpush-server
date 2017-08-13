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

name "unifiedpush-server"
default_version "1.2.0-SNAPSHOT"

dependency "ruby"
dependency "bundler"
dependency "rsync"
dependency "postgresql"
dependency "wildfly"

<<<<<<< HEAD
version "1.2.0-SNAPSHOT" do
  source md5: "ec754275290b58b0f4c038cd29f12361"
end
||||||| parent of 17167ac... Remove unused sources
source git: "https://github.com/aerobase/unifiedpush-server.git"
=======
source git: "https://github.com/C-B4/unifiedpush-server.git"
>>>>>>> 17167ac... Remove unused sources

version "1.2.0-RC1" do
  source md5: "f8f00ce9b554937445d0c9d4097f56ef"
end

repo_home = if "#{version}".end_with?("SNAPSHOT") then "libs-snapshot-local" else "libs-release-local" end

source url: "https://development.c-b4.com/artifactory/#{repo_home}/org/jboss/aerogear/unifiedpush/unifiedpush-package/#{version}/unifiedpush-package-#{version}.tar.gz"

build do
  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush-server/"
  sync "#{project_dir}/", "#{install_dir}/embedded/apps/unifiedpush-server/"

  # Strip version from packages.
  link "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server-wildfly-#{version}.war", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server.war"
  link "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-initdb-#{version}.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-initdb.tar.gz"
  link "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-keycloak-theme-#{version}.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-keycloak-theme.tar.gz"
  link "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui-#{version}.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui.tar.gz"

  erb source: "version.yml.erb",
      dest: "#{install_dir}/embedded/apps/unifiedpush-server/version.yml",
      mode: 0644,
      vars: { default_version: default_version }
end

# extract initdb project to allow JPA based schema creation.
build do
  command "tar xzf #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-initdb-#{version}.tar.gz -C #{install_dir}/embedded/apps/unifiedpush-server/"
end

