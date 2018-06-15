Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
exec { "docker_install_apt_key":
    onlyif  => "test $(apt-key list | grep docker | wc -l) -eq 0",
    command => "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
}
exec { "docker_add_repo":
    onlyif  => "test $(grep docker /etc/apt/sources.list | wc -l) -eq 0",
    command => "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'",
    require => Exec['docker_install_apt_key']
}
exec { "docker_upgate_ubuntu_packages_db":
    creates => "/usr/bin/docker",
    command => "apt-get update 2>&1 > /dev/null",
    require => Exec['docker_add_repo']
}
package{"docker-ce": 
    ensure  => installed,
    require => Exec['docker_upgate_ubuntu_packages_db']
}
