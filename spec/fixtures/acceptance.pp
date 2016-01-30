file { 'C:\share':
  ensure => directory,
}

file { 'C:\share\test.txt':
  ensure  => file,
  content => 'foo bar baz',
}

fileshare { 'test':
  ensure => present,
  path   => 'C:\share',
  maxcon => 10,
}
