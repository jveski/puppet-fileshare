fileshare
===================
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

Puppet module for managing fileshares.  At this time, only Windows CIFS shares are supported.

```
fileshare {'test_share_name':
  ensure      => present,
  provider    => wmi,
  source      => 'C:\test',
  permissions => { 'domain\user' => 'full'}
}
```
