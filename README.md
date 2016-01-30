#fileshare
[![Build Status](https://travis-ci.org/jolshevski/puppet-fileshare.svg)(https://travis-ci.org/jolshevski/puppet-fileshare)
[![Build status](https://ci.appveyor.com/api/projects/status/s08qgb4egku0pa3d?svg=true)

## Overview
A type/provider for managing Windows file shares with Puppet.

## Attributes
  * `ensure`  - Present/absent
  * `name`    - Name of the file share
  * `path`    - Path to the shared directory on the local filesystem
  * `comment` - An optional comment
  * `maxcon`  - Maximum allowed connections.  Defaults to 16777216.

## Access Control
This module ensures by default that shares allow full control access to everyone. It is expected that you will manage access rights with the `puppetlabs/acl` module at a filesystem level. An attribute `owner` is exposed if you need to override the default behavior, but proceed with caution.

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

### With Capped Concurrent Connections
```puppet
fileshare { 'the_file_share':
  ensure  => present,
  path    => 'C:\test',
  maxcon  => '10',
}
```
