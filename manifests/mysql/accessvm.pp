# Creates a view on keystone database
# presenting the amounts of project roles
# per user.

class profile::mysql::accessvm {
  $host = hiera('profile::mysql::ip')
  $pw = hiera('profile::mysqlcluster::root_password')
  $sql = "CREATE OR REPLACE VIEW v_project_roles_per_user AS \
          SELECT u.local_id AS username, count(p.name) AS project_roles \
          FROM project as p INNER JOIN assignment as a ON a.target_ID = p.id \
          INNER JOIN id_mapping u ON u.public_id = a.actor_id \
          GROUP BY username;"
  $accessuser = hiera('profile::access::db_user', false)
  $accesspw = hiera('profile::access::db_password', false)

  require ::profile::openstack::keystone

  if($accessuser) {
    $mysqlcommand = "/usr/bin/mysql -h ${host} \
                                    -uroot \
                                    -p${pw} \
                                    -D keystone \
                                    -e \"${sql}\" 2> /dev/null"

    $check_view = "/usr/bin/mysql -N -s -r -h ${host} \
                                  -uroot \
                                  -p${pw} \
                                  -D keystone \
                                  -e \"show tables;\" \
                                  | grep v_project_roles_per_user"


    exec { 'create_view':
      command => $mysqlcommand,
      user    => 'root',
      unless  => $check_view,
    } ->

    mysql_user { "${accessuser}@%":
      ensure        => 'present',
      password_hash => mysql_password($accesspw),
    } ->

    mysql_grant { "${accessuser}@%/keystone.v_project_roles_per_user":
      ensure     => 'present',
      privileges => ['SELECT'],
      table      => 'keystone.v_project_roles_per_user',
      user       => "${accessuser}@%",
    }
  }
}
