# Elasticsearch, Logstash and Kibana
class profile::monitoring::elk {

# E

  class { 'elasticsearch':
    autoupgrade  => true,
    java_install => true,
  }
  elasticsearch::instance { 'es-01': }

# L

  class { 'logstash':
    autoupgrade      => true,
    java_install     => true,
    install_contrib  => true,
  }
  logstash::configfile { 'logstash-syslog.conf':
    source => 'puppet:///modules/profile/monitoring/logstash-syslog.conf',
  }

# K

  class { 'kibana': }

}

