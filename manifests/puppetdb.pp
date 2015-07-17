class profile::puppetdb {

  class { '::java':
    distribution => 'jre',
  } ->
  class { '::puppetdb':
    confdir          => '/etc/puppetdb/conf.d',
    puppetdb_version => latest,
  }
  class { '::puppetdb::master::config':
    terminus_package => 'puppetdb-terminus',
  }

}
