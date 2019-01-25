# Installs and configures the bird routing-daemon
class profile::bird {
  include ::profile::bird::ipv4
  include ::profile::bird::ipv6
}
