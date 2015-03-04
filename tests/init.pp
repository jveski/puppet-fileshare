file { 'c:/test':
  ensure => directory,
}

fileshare { 'temptest':
  ensure  => present,
  path    => 'c:/test',
  comment => 'test comment...',
  maxcon  => 12,
}
