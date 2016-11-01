# Creates a view on keystone database
# presenting the amounts of project roles
# per user.

class profile::mysql::accessvm {
  $host = hiera('profile::mysql::ip')
  $pw = hiera('profile::mysqlcluster::root_password')
  $sql = 'CREATE VIEW v_project_roles_per_user AS \
          SELECT u.local_id AS username, count(p.name) AS project_roles \
          FROM project as p INNER JOIN assignment as a ON a.target_ID = p.id \
          INNER JOIN id_mapping u ON u.public_id = a.actor_id \
          GROUP BY username;'
  $accessuser = hiera('profile::access::db_user')
  $accesspw = hiera('profile::access::db_password')

  mysql::db { 'keystone':
    user     => 'root',
    password => $pw,
    host     => $host,
    sql      => $sql,
  } ->

  mysql_grant { "${accessuser}@172.16.%.%/keystone.v_project_roles_per_user":
    ensure     => present,
    options    => ['GRANT'],
    privileges => ['SELECT'],
    table      => 'keystone.v_project_roles_per_user',
    user       => "${accessuser}@172.16.%.%",
    password   => $accesspw,
  }
}
