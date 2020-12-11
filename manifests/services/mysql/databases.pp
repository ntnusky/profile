# Configures mysql with the appropriate databases
class profile::services::mysql::databases {
  include ::profile::monitoring::munin::plugin::vgpu::db
  include ::profile::services::dashboard::mysql
}
