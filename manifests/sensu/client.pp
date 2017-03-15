# Install and configure sensu-client
class profile::sensu::client {
  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')

  class { '::sensu':
    rabbitmq_host               => $rabbithost,
    rabbitmq_password           => $sensurabbitpass,
    rabbitmq_reconnect_on_error => true,
    server                      => false,
    api                         => false,
    client                      => true,
    sensu_plugin_provider       => 'sensu_gem',
    subscriptions               => [ 'all' ],
  }

  include ::profile::sensu::plugins
}
