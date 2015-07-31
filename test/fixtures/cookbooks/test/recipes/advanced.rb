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
