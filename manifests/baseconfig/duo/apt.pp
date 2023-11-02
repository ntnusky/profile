# Configures the apt-repo for the duo packages
class profile::baseconfig::duo::apt {
  apt::source { 'duo':
    architecture => 'amd64',
    comment      => '',
    location     => 'https://pkg.duosecurity.com/Ubuntu',
    key          => {
      id     => 'D8EC4E2058401AE5578C4B3F4B44CE3DFF696172',
      source => 'https://duo.com/DUO-GPG-PUBLIC-KEY.asc',
    },
    notify       => Exec['apt_update'],
  }
}
