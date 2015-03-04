#fileshare
[![Build Status](https://travis-ci.org/jolshevski/jordan-fileshare.svg?branch=master)](https://travis-ci.org/jolshevski/jordan-fileshare)

## Overview
Manage Windows file share resources with Puppet.

## Usage
```
fileshare { 'test_share_name':
  ensure  => present,
  path    => 'C:\test',
  comment => 'Optional Comment String Goes Here',
}
```

## Requirements
This module is tested on Windows 2008R2, 2012, and 2012R2.
