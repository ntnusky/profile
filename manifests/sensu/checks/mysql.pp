# Sensu checks for mysql servers
class profile::sensu::checks::mysql {
  sensu::check { 'mysql-status':
    aggregate   => 'galera-cluster',
    command     => 'check-mysql-status.rb -h localhost -d mysql -u clustercheck -p :::mysql.password::: --check status',
    interval    => 300,
    handle      => false,
    standalone  => false,
    subscribers => [ 'mysql' ],
  }
}
