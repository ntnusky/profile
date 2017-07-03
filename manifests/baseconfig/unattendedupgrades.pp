# Configure APT unattended upgrades
class profile::baseconfig::unattendedupgrades {
  $blacklist = hiera('profile::baseconfig::unattendedupgrades::blacklist', [])

  class { '::unattended_upgrades':
    blacklist     => $blacklist,
    minimal_steps => false,
  }
}
