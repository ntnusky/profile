class profile::managerbackups {
  cron { hieradata:
    command => 'scp -pr /etc/puppet/hieradata root@monitor:/opt/hieradata-backup',
    user    => root,
    hour    => '*/1',
  }
}
