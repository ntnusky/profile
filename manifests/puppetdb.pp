class profile::puppetdb {

  class { 'puppetdb': }
  class { 'puppetdb::master::config': }

}
