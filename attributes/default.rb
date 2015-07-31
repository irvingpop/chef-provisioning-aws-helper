# encoding: utf-8

# chef-zero attributes
default['chef-provisioning-aws']['chef_repo'] = Chef::Config[:chef_repo_path]
# default['chef-provisioning-aws']['key_path'] = File.join(Chef::Config[:chef_repo_path], 'keys')
default['chef-provisioning-aws']['vendor_cookbooks_path'] = ::File.join(Chef::Config[:chef_repo_path], 'vendor')

# machine details
default['chef-provisioning-aws']['region'] = 'us-west-2'
default['chef-provisioning-aws']['keypair_name'] = "#{ENV['USER']}@chef-provisioning-aws"
default['chef-provisioning-aws']['ssh_username'] = 'ec2-user'
default['chef-provisioning-aws']['use_private_ip_for_ssh'] = false

# bootstrap_options
default['chef-provisioning-aws']['instance_type'] = 't2.medium'
default['chef-provisioning-aws']['ebs_optimized'] = false
default['chef-provisioning-aws']['image_id'] = 'ami-4dbf9e7d' # RHEL 7.1 2015-02
default['chef-provisioning-aws']['subnet_id'] = nil
default['chef-provisioning-aws']['associate_public_ip_address'] = true
default['chef-provisioning-aws']['root_block_device'] = '/dev/sda1' # standard for most VMs, sometimes it is '/dev/sda'
default['chef-provisioning-aws']['root_block_device_size'] = 12 # in GB
default['chef-provisioning-aws']['root_block_device_type'] = 'gp2' # burstable SSD type

# tags: use a k,v format like { tagname: 'value', taname2: 'value2' }
default['chef-provisioning-aws']['aws_tags'] = {}

# convergence options for chef installation
default['chef-provisioning-aws']['install_sh_arguments'] = nil
default['chef-provisioning-aws']['bootstrap_proxy'] = nil
default['chef-provisioning-aws']['chef_config'] = nil
default['chef-provisioning-aws']['chef_version'] = nil

# override outdated values in the lvm cookbook
default['lvm']['di-ruby-lvm-attrib']['version'] = '0.0.20'
