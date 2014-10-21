if $::osfamily == 'Windows' {

  file { 'c:/test':
    ensure => directory,
  }

  fileshare { 'temptest':
    ensure      => present,
    path        => 'c:/test',
    comment     => 'test comment...',
  }
}
else {
  fail('Fileshare only supports Windows for the time being')
}
