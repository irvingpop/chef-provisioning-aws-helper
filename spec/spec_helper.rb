require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }

if defined?(ChefSpec)
  def converge_machine(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:machine, :converge, resource_name)
  end

  def download_machine_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:machine_file, :download, resource_name)
  end
end
