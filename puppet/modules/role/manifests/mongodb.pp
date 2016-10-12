class role::mongodb {
  include ::profile::base
  include ::profile::os_limits

  stage { 'swapfile':
    before => Stage['main'],
  }

  class { '::profile::swapfile':
    stage => swapfile
  }

  # from puppetlabs-mongodb/manifests/params.pp
  $pidfilepath  = '/var/run/mongodb/mongod.pid'

  $datapath     = hiera('mongodb::server::dbpath','/data/db')
  $datauser     = hiera('mongodb::server::user','mongod')
  $datagrp      = hiera('mongodb::server::grp','mongod')
  $serverpkg    = hiera('mongodb::server::package_name', 'mongodb-org-server')

  exec { "create_datafolder":
    command => "/usr/bin/mkdir -p ${datapath}",
  }

  file {"${datapath}":
    ensure => directory,
    mode   => '0755',
    owner => "${datauser}",
    group => "${datagrp}",
    require => [Package['mongodb_server'],Exec['create_datafolder']],
    before => Service['mongodb']
  }

  include ::profile::mongodb1
  #include ::profile::mongodb_repl_set_wt
  #include ::profile::mongodb_wt_backup

  package { 'mongodb-org-tools': ensure => installed, require => Yumrepo['mongodb'] }

     Service['mongodb']
  -> File[$pidfilepath]
  # Class['profile::mongodb1']
  #-> Class['profile::mongodb_repl_set_wt']
}