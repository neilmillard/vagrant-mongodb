class role::mongodb {
  include ::profile::base
  include ::profile::os_limits
  include selinux

  stage { 'swapfile':
    before => Stage['main'],
  }

  class { '::profile::swapfile':
    stage => swapfile
  }

  $datapath     = hiera('mongodb::server::dbpath','/data/db')

  exec { "create_datafolder":
    command => "/usr/bin/mkdir -p ${datapath}",
  }

  #include ::profile::mongodb1
  include ::profile::mongodb_repl_set_wt3
  #include ::profile::mongodb_wt_backup

  package { 'mongodb-org-tools': ensure => installed, require => Yumrepo['mongodb'] }

  # Class['profile::mongodb1']
  #-> Class['profile::mongodb_repl_set_wt']
}