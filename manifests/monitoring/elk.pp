# Elasticsearch, Logstash and Kibana
class profile::monitoring::elk {

# E

  class { 'elasticsearch':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.6',
    java_install => true,
  }
  elasticsearch::instance { 'es-01': }

# L

  class { 'logstash':
    autoupgrade      => true,
    manage_repo      => true,
    repo_version     => '1.5',
    java_install     => true,
    install_contrib  => true,
  }
  logstash::configfile { 'logstash-syslog.conf':
    source => 'puppet:///modules/profile/logstash-syslog.conf',
  }

# K

  class { 'kibana': }

}

