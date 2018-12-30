#
# Copyright:: Copyright (c) 2015
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

# The unifiedpush module in this file is used to parse /etc/unifiedpush/unifiedpush.rb.
#
# Warning to the reader:
# Because the Ruby DSL in /etc/unifiedpush/unifiedpush.rb does not accept hyphens (_) in
# section names, this module translates names like 'unifiedpush_server' to the
# correct 'unifiedpush-server' in the `generate_hash` method. This module is the only
# place in the cookbook where we write 'unifiedpush_server'.

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'
require 'uri'

module Unifiedpush
  extend(Mixlib::Config)

  bootstrap Mash.new
  global Mash.new
  user Mash.new
  java Mash.new
  cassandra Mash.new
  cassandra_config Mash.new
  postgresql Mash.new
  unifiedpush_server Mash.new
  keycloak_server Mash.new
  nginx Mash.new
  logging Mash.new
  logrotate Mash.new
  node nil
  external_url nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      SecretsHelper.read_unifiedpush_secrets

      # Note: If you add another secret to generate here make sure it gets written to disk in SecretsHelper.write_to_unifiedpush_secrets
      Unifiedpush['unifiedpush_server']['secret_token'] ||= generate_hex(64)

      # Note: Besides the section below, unifiedpush-secrets.json will also change
      # in CiHelper in libraries/helper.rb
      SecretsHelper.write_to_unifiedpush_secrets
    end

    def parse_external_url
      return unless external_url

      uri = URI(external_url.to_s)

      info("Installing according to external_url -> " + uri.host)

      unless uri.host
        raise "Unifiedpush external URL must include a schema and FQDN, e.g. http://unifiedpush.example.com/"
      end

      Unifiedpush['unifiedpush_server']['server_host'] = uri.host
      Unifiedpush['keycloak_server']['server_host'] = uri.host

      case uri.scheme
      when "http"
        Unifiedpush['unifiedpush_server']['server_https'] = false
      when "https"
        Unifiedpush['unifiedpush_server']['server_https'] = true
        Unifiedpush['nginx']['ssl_certificate'] ||= "/etc/unifiedpush/ssl/#{uri.host}.crt"
        Unifiedpush['nginx']['ssl_certificate_key'] ||= "/etc/unifiedpush/ssl/#{uri.host}.key"
      else
        raise "Unsupported external URL scheme: #{uri.scheme}"
      end

      unless ["", "/"].include?(uri.path)
        raise "Unsupported external URL path: #{uri.path}"
      end

      Unifiedpush['unifiedpush_server']['server_port'] = uri.port
    end

    def parse_postgresql_settings
      # If the user wants to run the internal Postgres service using an alternative
      # DB username, host or port, then those settings should also be applied to
      # unifiedpush.
      [
        # %w{unifiedpush_server db_username} corresponds to
        # Unifiedpush['unifiedpush_server']['db_username'], etc.
        [%w{unifiedpush_server db_username}, %w{postgresql sql_user}],
        [%w{unifiedpush_server db_host}, %w{postgresql listen_address}],
        [%w{unifiedpush_server db_port}, %w{postgresql port}]
      ].each do |left, right|
        if ! Unifiedpush[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # unifiedpush['db_port'] in unifiedpush.rb then we should never override
          # that.
          next
        end

        better_value_from_unifiedpush_rb = Unifiedpush[right.first][right.last]
        default_from_attributes = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        Unifiedpush[left.first][left.last] = better_value_from_unifiedpush_rb || default_from_attributes
      end
    end

    def parse_cassandra_settings
      # If the user wants to run the in symetric cluster mode,
      # then those settings should also be applied to cassandra / unifiedpush-server.
      [
        # %w{unifiedpush_server cas_contactpoints} corresponds to
        # Unifiedpush['unifiedpush_server']['cas_contactpoints'], etc.
        [%w{unifiedpush_server server_contactpoints}, %w{global contactpoints}],
        [%w{unifiedpush_server cas_contactpoints}, %w{global contactpoints}],
        [%w{cassandra seeds}, %w{global contactpoints}]
      ].each do |left, right|
        if ! Unifiedpush[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # unifiedpush['db_port'] in unifiedpush.rb then we should never override
          # that.
          next
        end

        better_value_from_unifiedpush_rb = Unifiedpush[right.first][right.last]
        default_from_attributes = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        Unifiedpush[left.first][left.last] = better_value_from_unifiedpush_rb || default_from_attributes
      end
    end

    def parse_nginx_listen_address
      return unless nginx['listen_address']

      # The user specified a custom NGINX listen address with the legacy
      # listen_address option. We have to convert it to the new
      # listen_addresses setting.
      nginx['listen_addresses'] = [nginx['listen_address']]
    end

    def parse_nginx_listen_ports
      [
        [%w{nginx listen_port}, %w{unifiedpush_server server_port}],

      ].each do |left, right|
        if !Unifiedpush[left.first][left.last].nil?
          next
        end

        default_set_server_port = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        user_set_server_port = Unifiedpush[right.first][right.last]

        Unifiedpush[left.first][left.last] = user_set_server_port || default_set_server_port
      end
    end

    def generate_hash
      results = { "unifiedpush" => {} }
      [
        "bootstrap",
        "global",
        "user",
	"java",
	"cassandra",
	"cassandra_config",
        "unifiedpush_server",
        "keycloak_server",
        "nginx",
        "logging",
        "logrotate",
        "postgresql",
        "external_url"
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['unifiedpush'][rkey] = Unifiedpush[key]
      end

      results
    end

    def generate_config(node_name)
      # generate_secrets(node_name)
      parse_external_url
      parse_postgresql_settings
      parse_cassandra_settings
      parse_nginx_listen_address
      parse_nginx_listen_ports
      # The last step is to convert underscores to hyphens in top-level keys
      generate_hash
    end
  end
end

class JavaHelper
  attr_reader :node

  def initialize(node)
    @node = node
      node['unifiedpush']['java'].each do |key, value|
        node.set['java'][key] = value
      end
  end
end

class CassandraHelper
  attr_reader :node

  def initialize(node)
    @node = node
      node['unifiedpush']['cassandra'].each do |key, value|
        node.set['cassandra'][key] = value
      end

      node['unifiedpush']['cassandra-config'].each do |key, value|
        node.set['cassandra']['config'][key] = value
      end
  end
end
