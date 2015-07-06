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
  file { '/etc/logstash/conf.d/logstash.conf':
    ensure => file,
    source => 'puppet:///modules/profile/logstash-logs.conf',
  }
# The following generates an error /Stage[main]/Logstash::Config/File_concat[ls-config]: 
# Failed to generate additional resources using 'eval_generate': undefined method `join' 
# for "puppet:///modules/profile/logstash-logs.conf" so we copy manually for now, see above
#  logstash::configfile { 'logstash-logs.conf':
#    source => 'puppet:///modules/profile/logstash-logs.conf',
#  }

# K

  class { '::kibana': }

}

