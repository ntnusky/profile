# Zabbix config for TLS checks
class profile::zabbix::agent::tls {

  $domains = lookup('zabbix::tls::expiry::domains', Hash[String, String])

  zabbix::userparameters { 'ssl_cert_check':
    content => join([
      'UserParameter=ssl_cert_check_valid[*], /usr/local/bin/ssl_cert_check.sh valid "$1" "$2" "$3" "$4" "$5"',
      'UserParameter=ssl_cert_check_expire[*], /usr/local/bin/ssl_cert_check.sh expire "$1" "$2" "$3" "$4" "$5"',
      'UserParameter=ssl_cert_check_json[*], /usr/local/bin/ssl_cert_check.sh json "$1" "$2" "$3" "$4" "$5"'
    ], "\n"),
  }

  zabbix::userparameters { 'ssl_cert_discovery':
    content => 'UserParameter=ssl_cert_list[*],/bin/cat /etc/zabbix/ssl_cert_list.json',
  }

  file { '/usr/local/bin/ssl_cert_check.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/zabbix/ssl_cert_check.sh',
  }

  $domain_list = $domains.map |$domain,$port| {
    {
      '{#IPADDR}'    => $domain,
      '{#SSLPORT}'   => $port,
      '{#SSLDOMAIN}' => $domain,
      '{#TIMEOUT}'   => "30",
    }
  }

  $domain_hash = {
    data => $domain_list
  }

  file { '/etc/zabbix/ssl_cert_list.json':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => template('profile/zabbix_agent/ssl_cert_list.erb'),
  }
}
