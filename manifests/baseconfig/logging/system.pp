# Configures default system logging
class profile::baseconfig::logging::system {
  # Enable filebeats system module
  profile::utilities::logging::module { 'system' :
    content => [{
      'module' => 'system',
      'syslog' => {
        'enabled' => true,
      },
      'auth' => {
        'enabled' => true,
      },
    }]
  }

  # Determine the typical system log-files not covered by the system module
  case $::operatingsystem {
    'CentOS': {
      $logfiles = [
        '/var/log/boot.log',
        '/var/log/cron',
        '/var/log/dmesg',
        '/var/log/maillog',
        '/var/log/yum.log',
        '/var/log/audit/audit.log',
        '/var/log/tuned/tuned.log',
      ]
    }
    'Ubuntu': {
      $logfiles = [
        '/var/log/alternatives.log',
        '/var/log/dpkg.log',
        '/var/log/kern.log',
        '/var/log/mail.log',
        '/var/log/unattended-upgrades/unattended-upgrades.log',
      ]

      profile::utilities::logging::file { 'apt-history':
        paths    => [
          '/var/log/apt/history.log',
        ],
        multiline => {
          'pattern' => 'Start-Date',
          'negate'  => 'true',
          'match'   => 'after',
          'timeout' => '30s',
        },
      }

      profile::utilities::logging::file { 'apt-term':
        paths    => [
          '/var/log/apt/term.log',
        ],
        multiline => {
          'pattern' => 'Log\ started',
          'negate'  => 'true',
          'match'   => 'after',
          'timeout' => '30s',
        },
      }
    }
    default: {
      fail("Unsopperted operating system: ${::operatingsystem}")
    }
  }

  # Input typical system-related logfiles
  profile::utilities::logging::file { 'syslogs':
    paths    => $logfiles,
    doc_type => 'log',
  }
}
