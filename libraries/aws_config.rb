# encoding: utf-8

# # example:
# aws_options('myhost.chef.io', config: {
#     ssh_username: 'ubuntu',
#     instance_type: 'm3.2xlarge',
#     ebs_optimized: true,
#     image_id: 'ami-13f4fb23'
#   }
# )

module AwsConfigHelper

  def aws_options(vmname = 'default.example.com', params = {})
    config = params[:config] || {}
    generate_aws_config(vmname, config)
  end

  # For the aws-sdk style chef-provisioning-aws
  def generate_aws_config(vmname, config)
    {
      :ssh_username => option_handler(config, :ssh_username),
      :use_private_ip_for_ssh => option_handler(config, :use_private_ip_for_ssh),
      :bootstrap_options => {
        :key_name => option_handler(config, :keypair_name),
        :instance_type => option_handler(config, :instance_type),
        :ebs_optimized => option_handler(config, :ebs_optimized),
        :image_id => option_handler(config, :image_id),
        :subnet_id => option_handler(config, :subnet_id),
        :associate_public_ip_address => option_handler(config, :associate_public_ip_address),
        # :user_data => nil, #TODO
        :block_device_mappings => [
          { device_name: option_handler(config, :root_block_device),
            ebs: {
              volume_size: option_handler(config, :root_block_device_size),
              volume_type: option_handler(config, :root_block_device_type),
              delete_on_termination: true
            }
          }
        ] + ephemeral_volumes(option_handler(config, :instance_type))
      },
      :aws_tags => option_handler(config, :aws_tags),
      :convergence_options => {
        :install_sh_arguments => option_handler(config, :install_sh_arguments),
        :bootstrap_proxy => option_handler(config, :bootstrap_proxy),
        :chef_config => option_handler(config, :chef_config),
        :chef_version => option_handler(config, :chef_version)
      }
    }
  end

  def option_handler(config, option)
    config[option.to_sym] || config[option.to_s] || node['chef-provisioning-aws'][option.to_s]
  end

  def ephemeral_volumes(instance_type)
    ephemeral_volumes = []
    number_volumes = instance_type_ephemeral_vols(instance_type)
    return ephemeral_volumes if number_volumes == 0
    1.upto(number_volumes).each do |i|
      array_pos = i - 1
      ephemeral_volumes << {device_name: diskmap[array_pos], virtual_name: "ephemeral#{array_pos}" }
    end
    ephemeral_volumes
  end

  def diskmap
    ('b'..'z').map { |l| "sd#{l}" }
  end

  def instance_type_ephemeral_vols(instance_type)
    case instance_type
    when 'i2.8xlarge'
      8
    when 'i2.4xlarge'
      4
    when 'm3.xlarge', 'm3.2xlarge', 'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge', 'r3.8xlarge', 'i2.2xlarge'
      2
    when 'm3.medium', 'm3.large', 'g2.2xlarge', 'r3.large', 'r3.xlarge', 'r3.2xlarge', 'r3.4xlarge', 'i2.xlarge'
      1
    else
      0
    end
  end

  def aws_instance_created?(vmname)
    rest = Chef::ServerAPI.new()
    begin
      nodeinfo = rest.get("/nodes/#{vmname}")
    rescue Net::HTTPServerException
      # Handle the 404 meaning the machine hasn't been created yet
      nodeinfo = {'normal' => { 'chef_provisioning' => {} } }
    end
    driver_info = nodeinfo['normal']['chef_provisioning']['reference'] || {}
    return true if driver_info.has_key?('instance_id')
    false
  end

end

Chef::Recipe.send(:include, AwsConfigHelper)
Chef::Resource.send(:include, AwsConfigHelper)
