# Creates a service to run the environment-discovery daemon
class profile::services::dashboard::service::envdiscovery {
  require ::profile::services::dashboard::install

  ::profile::systemd::service { 'envdiscovery':
    enable      => true,
    ensure      => 'running',
    command     => '/opt/shiftleader/daemons/puppetEnvDiscovery.sh',
    description => 'Daemon to poll r10k for new environments at SLs request',
  }
}
