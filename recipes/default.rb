#
# Cookbook Name:: ruby_enterprise
# Recipe:: default
#
# Author:: Mike Fiedler (<miketheman@gmail.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Sean Cribbs (<seancribbs@gmail.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
# 
# Copyright:: 2011-2012, Mike Fiedler
# Copyright:: 2009-2010, Opscode, Inc.
# Copyright:: 2009, Sean Cribbs
# Copyright:: 2009, Michael Hale
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

include_recipe "build-essential"

packages = value_for_platform(
  ["centos", "redhat", "fedora"] => {
    'default' => ['readline-devel', 'openssl-devel', 'patch']
  },
  ["ubuntu"] => {
    '12.04' => ['libreadline-dev', 'libssl-dev']
  },
  "default" => ['libreadline5-dev', 'libssl-dev']
)

packages.each do |pkg|
  package pkg
end

ree_ver = node['ruby_enterprise']['version']
ree_path = node['ruby_enterprise']['install_path']

remote_file "#{Chef::Config[:file_cache_path]}/ruby-enterprise-#{ree_ver}.tar.gz" do
  source "#{node['ruby_enterprise']['url']}.tar.gz"
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/ruby-enterprise-#{ree_ver}.tar.gz") }
end

bash "Install Ruby Enterprise Edition" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  tar zxf ruby-enterprise-#{ree_ver}.tar.gz
  ruby-enterprise-#{ree_ver}/installer \
    --auto=#{ree_path}
  EOH
  not_if do
    ::File.exists?("#{ree_path}/bin/ree-version") &&
      system("#{ree_path}/bin/ree-version | grep -q '#{ree_ver}$'")
  end
end
