require 'r10k/settings/collection'

# Handle a map of arbitrary key/value pairs.
class R10K::Settings::Map < R10K::Settings::Collection

  def initialize(name, &assign_block)
    @name = name
    @assign_block = assign_block
    @settings = {}
  end

  def assign(newvalue)
    newvalue.each_pair do |key, value|
      value = @assign_block.call(key, value)
      @settings[value.name] = value
    end
  end
end

__END__
R10K::Settings::MapDefinition.new(:repositories, {
  :instances => lambda do |key, value|
    R10K::Settings::GitRepoDefinition.new(key, value.merge(url: key))
  end
})
