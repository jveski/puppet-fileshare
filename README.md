#fileshare
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

## Overview
Manage Windows file shares with Puppet.

## Attributes
  * `ensure`  - Present/absent
  * `name`    - Name of the file share
  * `path`    - Path to the shared directory on the local filesystem
  * `comment` - An optional comment
  * `owner`   - Not intended to be modified.  Hash containing owner's sid, accessmask, and username.
  * `maxcon`  - Maximum allowed connections.  Defaults to 16777216.

## Usage
```
fileshare { 'test_share_name':
  ensure  => present,
  path    => 'C:\test',
  comment => 'Optional Comment String Goes Here',
}
```
