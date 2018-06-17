Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
$version     = "6.x"
    
exec { "install_nodejs":
    command => "curl -sL https://deb.nodesource.com/setup_$version | sudo -E bash - && sudo apt-get install -y nodejs",
    creates => "/usr/bin/node",
    timeout => "1200"
}

exec { "install_npm_pm2":
    require => Exec["install_nodejs"],
    path    => "/usr/bin",
    command => "/usr/bin/npm install pm2 -g",
    creates => "/usr/bin/pm2"
}

exec { "install_npm_bower":
    require => Exec["install_nodejs"],
    path    => "/usr/bin",
    command => "/usr/bin/npm install -g bower",
    creates => "/usr/bin/bower"
}

exec { "install_npm_gulp":
    require => Exec["install_nodejs"],
    path    => "/usr/bin",
    command => "/usr/bin/npm install -g gulp",
    creates => "/usr/bin/gulp"
}