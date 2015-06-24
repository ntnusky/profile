#
# The only trick here is to generate the certificate:
# wget https://github.com/driskell/log-courier/raw/master/src/lc-tlscert/lc-tlscert.g
# apt-get install golang
# go build lc-tlscert.go
# ./lc-tlscert
#

# Elasticsearch, Logstash and Kibana
class profile::monitoring::elk {

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
  file { '/etc/pki/tls/private/selfsigned.key':
    ensure => file,
    source => 'puppet:///modules/profile/keys/private/selfsigned.key',
  } ->
  file { '/etc/pki/tls/certs/selfsigned.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/certs/selfsigned.crt',
  } ->
  class { '::logstash':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.5',
    java_install => true,
#    install_contrib  => true, # DOES NOT WORK, contribs are being renamed 
#                              # with version 1.5, check this out later
  }
  logstash::configfile { 'logstash-syslog.conf':
    source => 'puppet:///modules/profile/logstash-syslog.conf',
  }

# K

  class { '::kibana': }

}

