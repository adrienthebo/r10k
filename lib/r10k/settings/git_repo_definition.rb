require 'r10k/settings/definition'
require 'uri'

class R10K::Settings::GitRepoDefinition < R10K::Settings::Definition

  def assign(newvalue)
    # TODO: symbolize
    super
  end

  def validate
    validate_type
    validate_keys
    validate_url
    validate_private_key
  end

  private

  def allowed_initialize_opts
    super.delete_if { |k, v| [:validate, :normalize].include?(k) }
  end

  def validate_type
    if !@value.is_a?(Hash)
      raise ArgumentError, "Git repository configuration should be a hash, not a #{@value.class}"
    end
  end

  def validate_keys
    unexpected_keys = @value.keys - [:url, :private_key]
    if !unexpected_keys.empty?
      raise ArgumentError, "Unexpected Git repository options: '#{unexpected_keys.inspect}'"
    end
  end

  # Validate that the provided URL is set and mostly sane.
  #
  # Because Git URLs are not necessarily valid URLs, we can't use URI.parse to validate this field.
  # RFC3986 uses a colon in the authority field to indicate an optional port, while the scp URL style
  # uses a colon to separate the hostname from the path component.
  def validate_url
    url = @value[:url]
    if url.nil?
      raise ArgumentError, "Git repository URL must be set"
    end

    if !url.is_a?(String)
      raise ArgumentError, "Git repository URL must be a String, not a #{url.class}"
    end
  end

  # Validate an optional private key field.
  #
  # It would be nice to ensure that this field is only set when the URL uses the SSH schema, but
  # because SSH urls can't necessarily be parsed by URI.parse nor do SSH URLs need to indicate
  # the protocol to use SSH it's nontrivial to add this validation.
  def validate_private_key
    private_key = @value[:private_key]
    if !(private_key.nil? || private_key.is_a?(String))
      raise ArgumentError, "Git repository SSH private key must be a String when set, not a #{private_key.class}"
    end
  end
end
