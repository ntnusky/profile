# Creates a service to run the r10k-deploy daemon
class profile::services::dashboard::service:r10kdeploy {
  require ::profile::services::dashboard::install

  ::profile::systemd::service { 'r10k-deploy':
    enable      => true,
    ensure      => 'running',
    command     => '/opt/shiftleader/daemons/r10kdeployer.sh',
    description => 'Daemon to deploy r10k environment when SL wants to',
  }
}
