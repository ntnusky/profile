# Install and configure sensu-server and dashboard
class ::profile::sensu::server: {
  require ::profile::services::redis

  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $mgmt_nic = hiera('profile::interfaces::management')

  class { '::sensu':
    rabbitmq_host         => $rabbithost,
    rabbitmq_password     => $sensurabbitpass,
    server                => true,
    api                   => true,
    use_embedded_ruby     => true,
    api_bind              => '127.0.0.1',
    sensu_plugin_provider => 'sensu_gem',
  }

  # Her skal uchiwa
}
