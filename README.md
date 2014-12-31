#fileshare
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

Puppet module for managing Windows fileshares.

## Requirements
This module is tested on Windows 2008R2, 2012, and 2012R2.

## Usage
```
fileshare { 'test_share_name':
  ensure  => present,
  path    => 'C:\test',
  comment => 'Optional Comment String Goes Here',
}
```
