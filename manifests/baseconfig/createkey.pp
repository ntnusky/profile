# Adds an ssh-key for a user.
define profile::baseconfig::createkey (
  String $username,
) {
  $key = hiera("profile::user::${username}::key::${name}")

  ssh_authorized_key { $name:
    user    => $username,
    type    => 'ssh-rsa',
    key     => $key,
    require => File["/home/${username}/.ssh"],
  }
}
