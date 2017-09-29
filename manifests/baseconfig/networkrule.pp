# Generates rules for selecting correct routing-tables. (Source:
# https://github.com/example42/puppet-network/blob/master/manifests/rule.pp).
# Created here as the source currently does not support IPv6.
define profile::baseconfig::networkrule (
  $iprule,
  $interface = $name,
  $family = undef,
) {
  file { "ruleup-${name}":
    ensure  => $ensure,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/network/if-up.d/z90-rule-${name}",
    content => template('rule_up.erb'),
    notify  => $::network::manage_config_file_notify,
  }
  file { "ruledown-${name}":
    ensure  => $ensure,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/network/if-down.d/z90-rule-${name}",
    content => template('rule_down.erb'),
    notify  => $::network::manage_config_file_notify,
  }
}
