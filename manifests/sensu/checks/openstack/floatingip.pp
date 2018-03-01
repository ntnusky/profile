# Sensu checks to monitor floating IP usage in our different pools
class profile::sensu::checks::openstack::floatingip {
  $openstack_api = hiera('profile::openstack::endpoint::public')

  sensu::check { 'openstack-floating-ip-rfc1918':
    command     => "/etc/sensu/plugins/extra/check_os_floating_ip.sh -p :::os.password::: -u ${openstack_api}:5000/v3 -s :::os.floating-rfc1918::: -w :::os.floating-rfc1918-warn|100::: -c :::os.floating-rfc1918-critical|50:::",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-infra-checks'],
  }
  sensu::check { 'openstack-floating-ip-gua':
    command     => "/etc/sensu/plugins/extra/check_os_floating_ip.sh -p :::os.password::: -u ${openstack_api}:5000/v3 -s :::os.floating-gua::: -w :::os.floating-gua-warn|100::: -c :::os.floating-gua-critical|50:::",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-infra-checks'],
  }
}
