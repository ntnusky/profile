# This class configures users based on information in hiera
class profile::baseconfig::users {
  # Configure users as instructed in hiera.
  $users = hiera('profile::users', false)
  if($users) {
    profile::baseconfig::createuser { $users: }
  }
}
