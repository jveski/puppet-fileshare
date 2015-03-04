Puppet::Type.newtype(:fileshare) do
  ensurable
  newparam(:name) do
    desc "Name of the file share"
    validate do |value|
      if value =~ /[<,>,:,",\/,\\,|,?,*]/
        fail Puppet::Error, "File share name '#{value}' must not contain the following values: <,>,:,\",/,\,|,?,*"
      end
    end
  end

  newparam(:path) do
    desc "Path to the shared directory on the local filesystem"
    validate do |value|
      unless Puppet::Util.absolute_path?(value, :windows)
        fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newproperty(:comment) do
    desc "An optional comment which will be made visible to clients"
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
    desc "The maximum number of allowed connections"
    validate do |value|
      numeric = %r{^-?(?:(?:[1-9]\d*)|0)$}
      unless value.is_a? Integer or (value.is_a? String and value.match numeric)
        fail Puppet::Error, "Maximum connections must be expressed as an integer"
      end
    end
    defaultto 16777216
  end

end
