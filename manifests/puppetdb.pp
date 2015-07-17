class profile::puppetdb {

  class { '::java':
    distribution => 'jre',
  } ->
  class { '::puppetdb':
    confdir          => '/etc/puppetdb/conf.d',
    postgres_version => '9.3',
  }
  class { '::puppetdb::master::config':
    terminus_package => 'puppetdb-terminus',
  }

}
