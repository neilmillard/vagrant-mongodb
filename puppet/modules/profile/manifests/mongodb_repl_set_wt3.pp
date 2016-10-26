# the mongodb replica set for the 'role service-pool1-mongodb-wt'
# uses the ::msmid_cluster_member_id fact

class profile::mongodb_repl_set_wt3 {

    $repl_domain          = hiera('profile::mongodb_replset::domain') # should NOT contain cluster_member_id e.g x1.
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


  include ::mongodb::globals
  include ::mongodb::server
  include ::mongodb::client

  file {'/etc/facter/facts.d/init_fhn.txt':
    content => "init_fhn=x${::msmid_cluster_member_id}.${repl_domain}",
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0644',
    require => Exec['install_sensu'],
  }

  Class['mongodb::globals']
  ->
  Class['mongodb::server']
  ->
  Class['mongodb::client']
  # handled by the wt3 script \|/
  # ->
  # mongodb_replset{"${mongodb_replset_name}":
  #   members => "${replset_members}"
  # }


  # nc is nmap-ncat on redhat 6
  $nc_package  = $::osfamily ? {
    'RedHat' => $::operatingsystemrelease ? {
      /^7\./        => 'nmap-ncat',
      default       => 'nc',
    },
    default         => 'nc',
  }

  package {"${nc_package}":
      ensure  => installed,
    }
    ->
  file { '/usr/local/bin/mongodb_replset3.sh':
    ensure  => present,
    mode    => '0755',
    owner   => root,
    group   => root,
    content => template('profile/mongodb/mongodb_replset_wt3.sh.erb'),
    require => [ Class['::mountdevice'], Class['profile::skydns_client'], File[$tls_pki_path], File['/etc/facter/facts.d/init_fhn.txt'], Class['mongodb::server'] ],
  }
  ->
  exec {'ensure_permissions_correct_wt3':
    command => '/bin/chmod -R u+x /var/lib/mongo'
  }
  ->
  exec { '/usr/local/bin/mongodb_replset3.sh':
    command     => '/usr/local/bin/mongodb_replset3.sh',
    provider    => shell,
    timeout     => 0,
    require     => [ File['/usr/local/bin/mongodb_replset3.sh'], Service['mongod'] ],
    environment => [
      "PKI_PATH=${tls_pki_path}",
      "PEM_PASS=${tls_chl_pass}",
      "SSL_MODE=${ssl_mode}",
      "USE_DB_AUTH=${db_auth}",
      "NUM_INSTANCES=${num_instances}"
    ],
  }
}
