#
# Cookbook Name:: chef-provisioning-aws-helper
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::ec2_ephemeral_mount' do
  context 'When all attributes are default, on CentOS 7.0' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(:platform => 'centos', :version => '7.0', step_into: 'ec2_ephemeral_mount') do |node|
        node.automatic['ec2'] = { "block_device_mapping_ephemeral0"=>"sdb",
                                  "block_device_mapping_ephemeral1"=>"sdc" }
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command("/sbin/lvm dumpconfig global/use_lvmetad | grep use_lvmetad=1").and_return(true)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

    it 'does the right things inside of the ec2_ephemeral_mount provider' do
      expect(chef_run).to umount_mount('/mnt')
      expect(chef_run).to disable_mount('/mnt')
      expect(chef_run).to install_package('xfsprogs')
      expect(chef_run).to create_lvm_volume_group('data_vg')
        .with(
          physical_volumes: %w(/dev/sdb /dev/sdc -f)
        )
      # TODO: figure out how to inspect what goes into logical_volume without
      #       causing errors from stepping into lvm_volume_group
    end

  end
end
