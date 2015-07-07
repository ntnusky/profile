#
# The only trick here is to generate the certificate:
# wget https://github.com/driskell/log-courier/raw/master/src/lc-tlscert/lc-tlscert.g
# apt-get install golang
# go build lc-tlscert.go
# ./lc-tlscert
#

# Elasticsearch, Logstash and Kibana
class profile::monitoring::elk {

  $logstash_key = hiera('profile::keys::logstash')

# E

  class { '::elasticsearch':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.6',
    java_install => true,
  }
  elasticsearch::instance { 'es-01': }

# L

  file { [ '/etc/pki/', '/etc/pki/tls/', '/etc/pki/tls/certs/',
  '/etc/pki/tls/private/' ]:
    ensure => directory,
  } ->
  file { '/etc/pki/tls/private/logstash.key':
    ensure  => file,
    content => "${logstash_key}",
  } ->
  file { '/etc/pki/tls/certs/logstash.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/certs/logstash.crt',
  } ->
  class { '::logstash':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.5',
    java_install => true,
#    install_contrib  => true, # DOES NOT WORK, contribs are being renamed 
#                              # with version 1.5, check this out later
  }
#  file { '/etc/logstash/conf.d/logstash.conf':
#    ensure => file,
#    source => 'puppet:///modules/profile/logstash-logs.conf',
#  }
# The following generates an error /Stage[main]/Logstash::Config/File_concat[ls-config]: 
# Failed to generate additional resources using 'eval_generate': undefined method `join' 
# for "puppet:///modules/profile/logstash-logs.conf" if using file_concat module newer than 0.3.0
  logstash::configfile { 'logstash-logs.conf':
    source => 'puppet:///modules/profile/logstash-logs.conf',
  }
  logstash::patternfile { 'openstack-patterns':
    source => 'puppet:///modules/profile/openstack-patterns',
  }


# K

  class { '::kibana': }

}

