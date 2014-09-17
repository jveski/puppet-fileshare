Puppet::Type.newtype(:fileshare) do
  ensurable
  newparam(:name) do
    desc "The name of the file share."
  end
  newparam(:path) do
    desc "Path to the shared directory."
  end
  newparam(:comment) do
    desc "An optional comment about the file share for fellow humans."
  end
  newparam(:max_con) do
    desc "An optional limit of maximum concurrent connections."
  end
  newparam(:permissions) do
    desc "A hash of user => permission pairs. Permissions can include Full Control, Change, and Read."
  end
end
