# chef-provisioning-aws-helper

This cookbook provides helper recipes and methods for using [chef-provisioning-aws](https://github.com/chef/chef-provisioning-aws)

# Usage

To establish identical settings for all of the machines in your cluster, set the following attributes in your wrapper cookbook:

```ruby
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
default['chef-provisioning-aws']['subnet_id'] = 'subnet-mysubnet'
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
```

Then simply use it in your recipe:

```ruby
include_recipe 'chef-provisioning-aws-helper::default'

machine "mario" do
  recipe 'mario::default'
  machine_options aws_options("mario.example.com")
end
```

# Advanced usage

You can override the settings on a per-machine basis like so:

```ruby
include_recipe 'chef-provisioning-aws-helper::default'

machine "mario" do
  recipe 'mario::default'
  machine_options aws_options("mario.example.com", config: {
    ssh_username: 'ubuntu',
    instance_type: 'm3.2xlarge',
    ebs_optimized: true,
    image_id: 'ami-13f4fb23',
    install_sh_arguments: '-P chefdk',
    root_block_device_size: 20,
    root_block_device_type: 'io1',
    aws_tags: { 'X-Project' => 'Chef_Secret' }
  })
end
```

# Ephemeral Mount resource
This cookbook also provides a resource to automatically LVM format, stripe and mount all of the ephemeral disks attached to the instance.  

Use like so:
```ruby
ec2_ephemeral_mount 'My Databass' do
  mount_point '/var/lib/mydatabass'
end
```
