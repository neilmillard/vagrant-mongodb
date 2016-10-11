# the mongodb replica set for the 'role service-pool1-mongodb-wt'
class profile::mongodb_repl_set_wt {

    $repl_domain          = hiera('profile::mongodb_replset::domain')
    $mongodb_replset_name = hiera('profile::mongodb_replset::mongodb_replset_name')
    $replset_members      = hiera('profile::mongodb_replset::members')
    $num_instances        = hiera('profile::mongodb_replset::num_instances', '2')
    $db_path              = hiera('mongodb::server::dbpath')
    $tls_pki_path         = hiera('profile::mongodb_replset::pki_path', '/etc/pki/mongodb')
    $tls_chl_pass         = hiera('ife_toolbelt::challenge_password','chanGEm3')
    $ssl_mode             = hiera('profile::mongodb::sslmode', 'preferSSL')
    $db_auth              = hiera('profile::mongodb::auth', false)
    # skydns config
    $etcd_host     = hiera('mongodb::skydns::etcd_host', 'etcd.internal')
    $etcd_port     = hiera('mongodb::skydns::etcd_port', '4001')
    $record_port   = hiera('mongodb::skydns::record_port', '27017')
    $record_ttl    = hiera('mongodb::skydns::record_ttl', '360')


  mongodb_replset{"${mongodb_replset_name}":
    members => "${replset_members}"
  }


  package {'nc':
      ensure  => installed,
    }
    ->
    file { '/usr/local/bin/mongodb_replset.sh':
      ensure  => present,
      mode    => '0755',
      owner   => root,
      group   => root,
      content => template('profile/mongodb/mongodb_replset_wt.sh.erb'),
      require => [
        #Class['::mountdevice'],
        #Class['profile::skydns_client'],
        #File[$tls_pki_path],
        Class['mongodb::server']
      ],
    }
    ->
    exec {'ensure_permissions_correct':
      command => '/bin/chmod -R +x /var/lib/mongo'
    }
    ->
    exec { '/usr/local/bin/mongodb_replset.sh':
      command     => '/usr/local/bin/mongodb_replset.sh',
      provider    => shell,
      timeout     => 0,
      require     => [
        File['/usr/local/bin/mongodb_replset.sh'],
        Service['mongod']
      ],
      environment => [
        "PKI_PATH=${tls_pki_path}",
        "PEM_PASS=${tls_chl_pass}",
        "SSL_MODE=${ssl_mode}",
        "USE_DB_AUTH=${db_auth}",
        "NUM_INSTANCES=${num_instances}"
      ],
    }
}
