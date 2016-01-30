Puppet::Type.newtype(:fileshare) do
  ensurable
  newparam(:name) do
    desc "Name of the file share."

    validate do |value|
      forbidden = ['<', '>', ':', '"', '/', '\\', '|', '?', '*'].join(',')

      if value =~ Regexp.new("[#{forbidden}]")
        fail Puppet::Error,
          "File share name '#{value}' must not contain the following values: #{forbidden}"
      end
    end
  end

  newparam(:path) do
    desc "Path to the shared directory on the local filesystem."

    validate do |value|
      is_absolute = Puppet::Util.absolute_path?(value, :windows)
      fail Puppet::Error, "File paths must be fully qualified, not '#{value}'" unless is_absolute
      fail Puppet::Error, "File paths must not end with a forward slash" if value =~ /\/$/
    end
  end

  newproperty(:comment) do
    desc "An optional comment which will be made visible to clients."
  end

  newproperty(:owner) do
    desc "A hash containing attributes about the owner.  Defaults to Everyone and should not be overriden in mode cases."

    defaultto({
      "accessmask" => "2032127",
      "sid" => [ 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ],
      "username" => "Everyone",
    })
  end

  newproperty(:maxcon) do
    desc "The maximum number of allowed connections."
    max = 16777216

    validate do |value|
      type = value.is_a?(Integer)
      fail Puppet::Error, "Maximum connections must be expressed as an integer" unless type
      fail Puppet::Error, "Maximum connections must be less than 16777216" if value > max
    end

    defaultto max
  end
end
