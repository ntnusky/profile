# Adds an ssh-key for a user.
define profile::baseconfig::createkey (
  $username,
) {
  $key = hiera("profile::user::${username}::key::${name}")

  if($username == 'root') {
    $homedir = '/root'
  } else {
    $homedir = "/home/${username}"
  }

  ssh_authorized_key { $name:
    user    => $username,
    type    => 'ssh-rsa',
    key     => $key,
    require => File["${homedir}/.ssh"],
  }
}
