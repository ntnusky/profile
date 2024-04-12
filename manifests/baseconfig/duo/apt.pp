# Configures the apt-repo for the duo packages
class profile::baseconfig::duo::apt {
  $location = lookup('profile::duo::apt::location', {
    'default_value' => 'https://pkg.duosecurity.com/Ubuntu',
    'value_type'    => Stdlib::HTTPUrl,
  })
  $key_id = lookup('profile::duo::apt::key::id', {
    'default_value' => 'D8EC4E2058401AE5578C4B3F4B44CE3DFF696172',
    'value_type'    => String,
  })
  $key_source = lookup('profile::duo::apt::key::source', {
    'default_value' => 'https://duo.com/DUO-GPG-PUBLIC-KEY.asc',
    'value_type'    => Stdlib::HTTPUrl,
  })

  apt::source { 'duo':
    architecture => 'amd64',
    comment      => '',
    location     => $location, 
    key          => {
      id     => $key_id, 
      source => $key_source, 
    },
    notify       => Exec['apt_update'],
  }
}
