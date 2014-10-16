if $::osfamily == 'Windows' {

  file {'c:/test':
    ensure => directory,
  }

  fileshare {'temptest':
    ensure      => present,
    path        => 'c:/test',
    comment     => 'test comment',
    max_con     =>  0,
  }
}
else {
  fail('Fileshare only supports Windows for the time being')
}
