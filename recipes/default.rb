#
# Cookbook Name:: chef-provisioning-aws-helper
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# This recipe sets up a local chef-zero server for provisioning - note the paths from the attributes file

require 'chef/provisioning/aws_driver'

with_chef_local_server :chef_repo_path => node['chef-provisioning-aws']['chef_repo'],
  :cookbook_path => [ node['chef-provisioning-aws']['vendor_cookbooks_path'] ],
  :port => 9010.upto(9999)

with_driver "aws::#{node['chef-provisioning-aws']['region']}"

keypair_name  = node['chef-provisioning-aws']['keypair_name']
key_dir       = Chef::Config.private_key_paths.first
private_key   = File.join(key_dir, keypair_name)
public_key    = File.join(key_dir, "#{keypair_name}.pub")

# I want to take an axe to this code: https://github.com/chef/cheffish/blob/master/lib/cheffish.rb#L99
if keypair_name.include?('.')
  raise "keypair_name #{keypair_name} unsupported at the moment because it contains dot (.) characters"
end

unless Dir.exist?(key_dir) && File.exist?(private_key) && File.exist?(public_key)

  log "Generating AWS keypair #{keypair_name} for you at #{key_dir}"

  directory key_dir do
    mode '0700'
    recursive true
    action :create
  end

  execute 'generate key' do
    command "ssh-keygen -f #{private_key} -N ''"
    action :run
    creates private_key
  end
end

aws_key_pair keypair_name do
  private_key_path private_key
  public_key_path public_key
end
