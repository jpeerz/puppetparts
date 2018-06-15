Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
$jenkins_port   = '8383'
$jenkins_user   = 'jenkins'
$jenkins_group  = 'jenkins'
exec { "install_jenkins_key":
    command => "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
    onlyif  => "test $(apt-key list | grep kawaguchi | wc -l) -eq 0"
}
exec { "install_jenkins_repo":
    command => "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'",
    creates => '/etc/apt/sources.list.d/jenkins.list',
    require => Exec["install_jenkins_key"]
}
exec { "update_ubuntu_repos":
    command => "apt-get update > /dev/null",
    creates => '/usr/share/jenkins',
    require => Exec["install_jenkins_repo"]
}
package { "jenkins":
    ensure  => installed,
    require => Exec["update_ubuntu_repos"]
}
file { "/var/lib/jenkins":
    ensure  => directory,
    replace => no,
    owner   => jenkins,
    group   => jenkins,
    require => Package["jenkins"]
}
file { "/var/cache/jenkins":
    ensure  => directory,
    recurse => true,
    replace => no,
    owner   => jenkins,
    group   => jenkins,
    require => File["/var/lib/jenkins"]
}
file { "/var/log/jenkins":
    ensure  => directory,
    recurse => true,
    replace => no,
    owner   => jenkins,
    group   => jenkins,
    require => File["/var/cache/jenkins"]
}
file { "/etc/default/jenkins":
    ensure  => file,
    backup  => true,
    path    => '/etc/default/jenkins',
    content => 'puppet://modules/core/etc_default_jenkins',
    require => File["/var/lib/jenkins"]
} 
exec { "bypass_jenkins_initial_config":
    command => "mv /var/lib/jenkins/secrets/initialAdminPassword /opt/ && cat /opt/initialAdminPassword",
    onlyif  => 'test -f /var/lib/jenkins/secrets/initialAdminPassword'
}
service { "jenkins":
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/default/jenkins']
}
