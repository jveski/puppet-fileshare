Puppet::Type.newtype(:fileshare) do

  ensurable
  newparam(:name) do
    desc "Name of the file share."
    validate do |value|
      fail Puppet::Error, "File share name '#{value}' must not contain the following values: <,>,:,\",/,\,|,?,*" if value =~ /[<,>,:,",\/,\\,|,?,*]/
    end
  end

  newparam(:path) do
    desc "Path to the shared directory on the local filesystem."
    validate do |value|
      fail Puppet::Error, "File paths must be fully qualified, not '#{value}'" unless Puppet::Util.absolute_path?(value, :windows)
      fail Puppet::Error, "File paths must not end with a forward slash" if value =~ /\/$/
    end
  end

  newproperty(:comment) do
    desc "An optional comment which will be made visible to clients."
  end

  newproperty(:owner) do
    desc "A hash containing attributes about the owner.  Defaults to Everyone and should not be overriden in mode cases."
    hash = { 
      "accessmask" => "2032127",
      "sid" => [ 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ],
      "username" => "Everyone",
    }
    defaultto hash
  end

  newproperty(:maxcon) do
    desc "The maximum number of allowed connections."
    validate do |value|
      unless value.is_a?(Integer) || value.is_a?(String) && value =~ /^-?(?:(?:[1-9]\d*)|0)$/
        fail Puppet::Error, "Maximum connections must be expressed as an integer"
      end
    end
    defaultto 16777216
  end

end
