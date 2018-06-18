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

name "unifiedpush-admin-ui"
default_version "v1.2.3"

dependency "ruby"
dependency "bundler"
dependency "rsync"

source git: "https://github.com/C-B4/unifiedpush-admin-ui.git"

relative_path "unifiedpush-admin-ui"
build_dir = "#{project_dir}"

build do
  command "mvn clean install -DskipTests"

  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush-server/"

  # Strip version from packages.
  copy "#{project_dir}/target/unifiedpush-admin-ui.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui.tar.gz"
end
