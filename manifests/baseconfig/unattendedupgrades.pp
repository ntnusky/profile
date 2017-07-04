# Configure APT unattended upgrades
#
# All parameters can be overridden in hiera , i.e:
#  unattended_upgrades::blacklist:
#   'vim'
#   'openssl'
#  unattended_upgrades::upgrade: 7
#

class profile::baseconfig::unattendedupgrades {
  class { '::unattended_upgrades':
    minimal_steps => false,
  }
}
