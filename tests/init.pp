file {'c:/test':
  ensure => directory,
}

win_fileshare {'temptest':
  ensure      => present,
  path        => 'c:/test',
  comment     => 'test comment',
  max_con     =>  0,
  permissions =>  { 'WIN-0QPGSKB8HDD\vagrant' => 'full'}
}
