#
# Cookbook Name:: chef-provisioning-aws-helper
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'chef-provisioning-aws-helper::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end

describe 'test::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

    it 'converges the machine with the correct machine_options' do
      expect(chef_run).to converge_machine('mario')
        .with(machine_options: {:ssh_username=>"ec2-user",
         :use_private_ip_for_ssh=>false,
         :bootstrap_options=>
          {:key_name=>"irving@chef-provisioning-aws",
           :instance_type=>"t2.medium",
           :ebs_optimized=>false,
           :image_id=>"ami-4dbf9e7d",
           :subnet_id=>nil,
           :associate_public_ip_address=>true,
           #  :user_data=>nil,
           :block_device_mappings=>
            [{:device_name=>"/dev/sda1", :ebs=>{:volume_size=>12, :volume_type=>"gp2", :delete_on_termination=>true}}]},
         :aws_tags=>{},
         :convergence_options=>{:install_sh_arguments=>nil, :bootstrap_proxy=>nil, :chef_config=>nil, :chef_version=>nil}}
        )
    end
  end
end

describe 'test::advanced' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

it 'converges the machine with the correct machine_options' do
      expect(chef_run).to converge_machine('mario')
        .with(machine_options: {
          :ssh_username=>"ubuntu",
           :use_private_ip_for_ssh=>false,
           :bootstrap_options=>
            {:key_name=>"irving@chef-provisioning-aws",
             :instance_type=>"m3.2xlarge",
             :ebs_optimized=>true,
             :image_id=>"ami-13f4fb23",
             :subnet_id=>nil,
             :associate_public_ip_address=>true,
             #  :user_data=>nil,
             :block_device_mappings=>
              [{:device_name=>"/dev/sda1", :ebs=>{:volume_size=>20, :volume_type=>"io1", :delete_on_termination=>true}},
               {:device_name=>"sdb", :virtual_name=>"ephemeral0"},
               {:device_name=>"sdc", :virtual_name=>"ephemeral1"}
               ]},
           :aws_tags=>{"X-Project"=>"Chef_Secret"},
           :convergence_options=>{:install_sh_arguments=>"-P chefdk", :bootstrap_proxy=>nil, :chef_config=>nil, :chef_version=>nil}
         }
        )
    end
  end
end
