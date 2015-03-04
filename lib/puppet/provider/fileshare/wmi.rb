Puppet::Type.type(:fileshare).provide(:wmi) do
  desc "Manage Windows File Shares"
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  require File.expand_path("../wmi/fileshare", __FILE__)
  require File.expand_path("../wmi/securitydescriptor", __FILE__)

  def create
    obj = Fileshare.new(@resource[:name])
    obj.path = @resource[:path]
    obj.create

    # Ensure the properties have been managed
    self.owner = @resource.should(:owner) unless self.owner == @resource.should(:owner)
    self.comment = @resource.should(:comment) unless self.comment == @resource.should(:comment)
    self.maxcon = @resource.should(:maxcon) unless self.maxcon == @resource.should(:maxcon)
  end

  def destroy
    Fileshare.new(@resource[:name]).delete
  end

  def exists?
    Fileshare.new(@resource[:name]).exists?
  end

  def owner
    share = Fileshare.new(@resource[:name])
    return :absent unless share.dacl[0]
    {
      'accessmask' => String(share.dacl[0].accessmask),
      'sid' => share.dacl[0].trustee.sid,
      'username' => share.dacl[0].trustee.name,
    }
  end

  def owner=(owner_hash)
    share = Fileshare.new(@resource[:name])
    sd = SecurityDescriptor.new
    sd.username = owner_hash['username']
    sd.sid = owner_hash['sid']
    share.sd = sd.sd
  end

  def comment
    obj = Fileshare.new(@resource[:name])
    return :absent unless obj.comment
    obj.comment
  end

  def comment=(string)
    obj = Fileshare.new(@resource[:name])
    obj.comment = string
  end

  def maxcon
    obj = Fileshare.new(@resource[:name])
    return :absent unless obj.maxcon
    obj.maxcon
  end

  def maxcon=(int)
    obj = Fileshare.new(@resource[:name])
    obj.maxcon = int
  end

end
