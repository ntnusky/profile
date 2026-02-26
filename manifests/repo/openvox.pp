# Configures an appropriate apt-repo for the openvox tools.
class profile::repo::openvox {
  $reponame = lookup('profile::openvx::release', {
    'default_value' => 'openvox8',
    'value_type'    => String,
  })

  include apt

  $os_name = downcase($facts['os']['name'])
  apt::source { "${reponame}-release":
    comment  => "${reponame} ${os_name}${facts['os']['release']['major']} Repository",
    location => 'https://apt.voxpupuli.org',
    release  => "${os_name}${facts['os']['release']['major']}",
    repos    => $reponame,
    key      => {
      'name'   => 'openvox-keyring.gpg',
      'source' => 'https://apt.voxpupuli.org/openvox-keyring.gpg',
    },
  }
}
