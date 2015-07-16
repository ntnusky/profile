class profile::puppetdb {

  class { '::puppetdb': }
  class { '::puppetdb::master::config':
    terminus_package => 'puppetdb-terminus',
    confdir          => '/etc/puppetdb/conf.d',
  }

}
