class profile::users::nova {
  user { 'nova':
    shell       => '/bin/bash',
  }
}
