# Class for configuring OS locale
class profile::baseconfig::locale {
  $default_locale = lookup('profile::locales::default', {
      'default_value' => 'en_US.UTF-8', # Override module default of "C"
      'value_type'    => String
  })
  $locales = lookup('profile::locales', {
      'default_value' => ['en_US.UTF-8 UTF-8', 'en_GB.UTF8 UTF-8'], # Override module default (en_US, de_DE)
      'value_type'    => Array[String]
  })

  class { 'locales':
    default_locale => $default_locale,
    locales        => $locales,
  }
}
