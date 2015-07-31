
include_recipe 'chef-provisioning-aws-helper::default'

machine 'mario' do
  recipe 'mario::default'
  machine_options aws_options('mario.example.com')
end
