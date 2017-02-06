# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::ssh
}
