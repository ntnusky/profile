# Define an apache vhost for random static info
class profile::services::info {
  $vhost = lookup('profile::info::maillist::fqdn')
  $management_if = lookup('profile::interfaces::management')
  $management_ipv4 = $::facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']

  require ::profile::services::apache
  contain ::profile::services::info::maillist

  apache::vhost { "${vhost} http":
    servername => $vhost,
    port       => '80',
    ip         => concat([], $management_ipv4, $management_ipv6),
    add_listen => false,
    docroot    => "/var/www/${vhost}",
  }
}
