# This class installs and configures remote-logging for our servers.
class profile::baseconfig::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    # Install and configure filebeat.
    class { 'filebeat':
      enable_conf_modules => true,
      modules => [
        'apache',
        'haproxy',
        'iptables',
        'mysql',
        'postgresql',
        'rabbitmq',
        'redis',
        'system',
      ],
      outputs => {
        'logstash' => {
          'hosts'       => $loggservers,
          'loadbalance' => true,
        },
      },
    }

    ## Determine the typical system log-files
    #case $::operatingsystem {
    #  'CentOS': {
    #    $logfiles = [
    #      '/var/log/boot.log',
    #      '/var/log/cron',
    #      '/var/log/dmesg',
    #      '/var/log/maillog',
    #      '/var/log/messages',
    #      '/var/log/secure',
    #      '/var/log/yum.log',
    #      '/var/log/audit/audit.log',
    #      '/var/log/tuned/tuned.log',
    #    ]
    #  }
    #  'Ubuntu': {
    #    $logfiles = [
    #      '/var/log/alternatives.log',
    #      '/var/log/auth.log',
    #      '/var/log/dpkg.log',
    #      '/var/log/kern.log',
    #      '/var/log/mail.log',
    #      '/var/log/syslog',
    #      '/var/log/unattended-upgrades/unattended-upgrades.log',
    #    ]

    #    filebeat::input { 'apt-history':
    #      paths    => [
    #        '/var/log/apt/history.log',
    #      ],
    #      doc_type => 'log',
    #      multiline => {
    #        'pattern' => 'Start-Date',
    #        'negate'  => 'true',
    #        'match'   => 'after',
    #        'timeout' => '30s',
    #      },
    #    }

    #    filebeat::input { 'apt-term':
    #      paths    => [
    #        '/var/log/apt/term.log',
    #      ],
    #      doc_type => 'log',
    #      multiline => {
    #        'pattern' => 'Log\ started',
    #        'negate'  => 'true',
    #        'match'   => 'after',
    #        'timeout' => '30s',
    #      },
    #    }
    #  }
    #  default: {
    #    fail("Unsopperted operating system: ${::operatingsystem}")
    #  }
    #}

    ## Input typical system-related logfiles
    #filebeat::input { 'syslogs':
    #  paths    => $logfiles,
    #  doc_type => 'log',
    #}
  }
}
