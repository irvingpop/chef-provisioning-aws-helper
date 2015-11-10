# encoding: utf-8

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class Ec2EphemeralMount < Chef::Resource::LWRPBase
      self.resource_name = :ec2_ephemeral_mount
      actions :create
      default_action :create
      attribute :mount_point, :kind_of => String, :name_attribute => true
    end
  end
end

require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class Ec2EphemeralMount < Chef::Provider::LWRPBase
      use_inline_resources

      provides :ec2_ephemeral_mount

      action :create do
        run_context.include_recipe 'lvm::default'
        unmount_mnt
        lvm_mount(translated_ephemeral_devices, fs_type, new_resource.mount_point)
      end

      def unmount_mnt
        mnt_dev = node.filesystem.select { |k,v| v['mount'] == '/mnt' }.keys.first || '/dev/null'

        mount '/mnt' do
          device mnt_dev
          action [:umount, :disable]
        end
      end

      # returns ['sdb', 'sdc']
      def ephemeral_devices
        return {} unless node['ec2']
        node['ec2'].select { |k,v| k =~ /block_device_mapping_ephemeral/ }.values
      end

      def translated_ephemeral_devices
        if rootdev.include?('/dev/xvd')
          ephemeral_devices.map { |dev| dev.gsub('sd', '/dev/xvd') }
        else
          ephemeral_devices.map { |dev| "/dev/#{dev}" }
        end
      end

      def rootdev
        node.filesystem.select { |k,v| v['mount'] == '/' }.keys.first
      end

      def fs_type
        if node['platform_family'] == 'debian' || node['platform'] == 'centos' || (node['platform'] == 'redhat' && node['platform_version'].to_i >= 7)
          package 'xfsprogs'
          'xfs'
        elsif system('which mkfs.ext4')
          'ext4'
        else
          'ext3'
        end
      end

      def lvm_mount(devices, fstype, mountpoint)
        lvm_volume_group 'data_vg' do
          physical_volumes devices + ['-f']  # stupid trick to force formatting on RHEL7

          logical_volume 'data_lv' do
            size        '80%VG'
            filesystem fstype
            mount_point mountpoint
            stripes devices.length
          end
        end
      end

    end
  end
end
