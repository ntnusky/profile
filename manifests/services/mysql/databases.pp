# Configures mysql with the appropriate databases
class profile::services::mysql::databases {
  include ::shiftleader::database
}
