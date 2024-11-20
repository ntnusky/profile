# Configures mysql with the appropriate databases
class profile::services::mysql::databases {
  $sl2dbpassword = lookup('shiftleader::params::database_password', {
    'default_value' => undef,
    'value_type'    => Optional[String], 
  })
  if($sl2dbpassword) {
    include ::shiftleader::database
  }
}
