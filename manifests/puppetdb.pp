class profile::puppetdb {

  class { '::puppetdb':
    confdir          => '/etc/puppetdb/conf.d',
  }
  class { '::puppetdb::master::config':
    terminus_package => 'puppetdb-terminus',
  }

}
