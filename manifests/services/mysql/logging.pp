# Configure filebeat for mysql logs 
class profile::services::mysql::logging {
  profile::utilities::logging::module { 'mysql' : }
}
