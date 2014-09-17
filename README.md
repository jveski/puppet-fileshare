fileshare (WORK IN PROGRESS!)
===================
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

Puppet module to manage fileshares.  For the time being, only Windows CIFS shares are supported.

```
fileshare {'test_share_name':
  ensure      => present,
  provider    => wmi,
  source      => 'C:\test',
  permissions => { 'domain\user' => 'full'}
}
```