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

name "cassandra-unit"
default_version "master"

dependency "ruby"
dependency "bundler"
dependency "rsync"

relative_path "cassandra-unit"
build_dir = "#{project_dir}"

# TEMP Solution until cassandra-unit 3.1.4.0 will be released.
build do
  command "mvn clean install -DskipTests"
end
