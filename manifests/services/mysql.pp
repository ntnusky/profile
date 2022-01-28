# Transitional class left for compatibility. Use
# profile::services::mysql::cluster instead.
class profile::services::mysql {
  contain ::profile::services::mysql::cluster
}
