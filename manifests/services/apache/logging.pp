# This class configures log-inputs from apache
class profile::services::apache::logging {
  profile::utilities::logging::module { 'apache' : }
}
