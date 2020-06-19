# Abstraction for selecting correct auto-update package based on OS
class profile::baseconfig::updates {
  case $::operatingsystem {
    'CentOS': {
      include ::profile::baseconfig::updates::yumcron
    }
    'Ubuntu': {
      include ::profile::baseconfig::updates::unattendedupgrades
    }
    default: {
      fail("Unsopperted operating system: ${::operatingsystem}")
    }
  }
}

