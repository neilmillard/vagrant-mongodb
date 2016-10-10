# profile::mongodb1
class profile::mongodb1 {
  include ::mongodb::globals
  include ::mongodb::server
  include ::mongodb::client

  Class['mongodb::globals'] -> Class['mongodb::server']
  Class['mongodb::globals'] -> Class['mongodb::client']
}
