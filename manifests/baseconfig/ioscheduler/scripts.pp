# Installs utility-scripts for ioscheduler-tuning
class profile::baseconfig::ioscheduler::scripts {
  $scripts = [
    'get-io-queue.sh', 'verify-io-queue.sh',
    'get-io-scheduler.sh', 'verify-io-scheduler.sh',
  ]

  $scripts.each | $script | {
    file { "/usr/local/bin/${script}":
      ensure => file,
      source => 'puppet:///modules/profile/utilities/${script}',
      mode   => '0555',
    }
  }
}
