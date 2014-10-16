Puppet::Type.newtype(:fileshare) do
  ensurable
  newparam(:name) do
    desc "The name of the file share."
    validate do |value|
      if value =~ /[<,>,:,",\/,\\,|,?,*]/
        raise ArgumentError, 'Share name must not contain the following values: <,>,:,",/,\,|,?,*' % value
      end
    end
  end

  newparam(:path) do
    desc "Path to the shared directory."
    validate do |value|
      unless value =~ /[a-z][:]\//
        raise ArgumentError, 'Share path must be valid, absolute file path' % value
      end
    end
  end

  newparam(:comment) do
    desc "An optional comment about the file share for fellow humans."
  end

  newparam(:max_con) do
    desc "An optional limit of maximum concurrent connections."
    validate do |value|
      unless value =~ /\d+$/
        raise ArgumentError, 'Max connections must be expressed in a number.' % value
      end
    end
  end

  newparam(:permissions) do
    desc "A hash of user => permission pairs. Permissions can include Full Control, Change, and Read."
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, 'Permissions must be expressed in a hash' % value 
      end
      value.each do |key, value|
        unless value == 'full' || value == 'change' || value == 'read'
          raise ArgumentError, 'Permissions can only be set to full, change, or read.' % value
        end
      end
    end
  end

end
