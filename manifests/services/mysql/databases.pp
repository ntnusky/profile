# Configures mysql with the appropriate databases
class profile::services::mysql::databases {
  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  include ::profile::monitoring::munin::plugin::vgpu::db

  # Create the correct database for shiftleader.
  # TODO: Remove the database for SL1 when all platforms are migrated
  if($sl_version == 1) {
    include ::profile::services::dashboard::mysql
  } else {
    include ::shiftleader::database
  }
}
