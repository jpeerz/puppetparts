Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
# include mongodb
$mongodb_version = "3.4"
$lsb_release = "xenial"

exec { "install_mongodb_key":
    command => "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6",
    onlyif  => "test $(apt-key list | grep mongodb | wc -l) -eq 0"
}

exec { "install_mongodb_repo":
    command => "echo 'deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu $lsb_release/mongodb-org/${mongodb_version} multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list",
    creates => "/etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list",
    require => Exec["install_mongodb_key"]
}

exec { "update_ubuntu_mongodb_repos":
    command => "sudo apt-get update > /dev/null",
    creates => "/var/run/mongodb.pid",
    require => [Exec["install_mongodb_repo"],Exec["install_mongodb_key"]]
}

package { "mongodb-org":
    ensure  => installed,
    require => Exec["update_ubuntu_mongodb_repos"]
}

file { "/etc/mongod.conf":
    ensure  => file,
    backup  => true,
    content => template('core/mongod.conf'),
    require => Package["mongodb-org"]
}

exec { "reload_mongodb_insecure":
    creates => "/var/run/mongodb.pid",
    command => "/usr/bin/mongod --noauth --config /etc/mongod.conf",
    require => File["/etc/mongod.conf"]
}

# exec { "reload_mongodb_secure":
#     creates => "/var/run/mongodb.pid",
#     command => "/usr/bin/mongod --shutdown --config /etc/mongod.conf && /usr/bin/mongod --auth --config /etc/mongod.conf",
#     require => Exec["setup_admin_user"]
# }
