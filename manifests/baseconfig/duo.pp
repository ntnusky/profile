# Installs and configures DUO
class profile::baseconfig::duo {
  include ::profile::baseconfig::duo::apt
  include ::profile::baseconfig::duo::configure
  include ::profile::baseconfig::duo::install
}
