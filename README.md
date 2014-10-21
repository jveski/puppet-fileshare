fileshare
===================
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

Puppet module to manage fileshares.  For the time being, only Windows CIFS shares are supported.

```
fileshare { 'test_share_name':
  ensure  => present,
  path    => 'C:\test',
  comment => 'Optional Comment String Goes Here',
}
```
