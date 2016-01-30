#fileshare
[![Build Status](https://travis-ci.org/jolshevski/puppet-fileshare.svg)](https://travis-ci.org/jolshevski/puppet-fileshare)
![Windows Build Status](https://ci.appveyor.com/api/projects/status/s08qgb4egku0pa3d?svg=true)

## Overview
A Puppet resource type for managing Windows file shares.

## Attributes
  * `name`    - Name of the file share (namevar)
  * `path`    - Path to the shared directory
  * `comment` - An optional comment
  * `maxcon`  - Maximum allowed connections.  Defaults to 16777216.

## Access Control
This module ensures by default that shares allow full control access to everyone. It is expected that you will manage access rights with the `puppetlabs/acl` module at a filesystem level.

## Usage
```puppet
fileshare { 'the_file_share':
  ensure  => present,
  path    => 'C:\test',
}
```

### With Comment
```puppet
fileshare { 'the_file_share':
  ensure  => present,
  path    => 'C:\test',
  comment => 'Optional Comment String Goes Here',
}
```
