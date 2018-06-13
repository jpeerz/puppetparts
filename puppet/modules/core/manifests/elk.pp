Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
# include elk
$elasticsearch_cluster_name = "elk"
$kibana_server_port         = 5601
$kibana_server_ip           = "127.0.0.1"
$kibana_conf                = "core/kibana.min.yml"
$elasticsearch_server_ip    = "127.0.0.1"
$elasticsearch_server_port  = 9200
$elasticsearch_jvm          = "core/jvm.min.options"
$elasticsearch_conf         = "core/elasticsearch.min.yml"
exec {"apt_key_elastic_co":
    command => "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
    onlyif  => "test $(apt-key list | grep Elasticsearch | wc -l) -eq 0"
}
exec {"apt_add_elastic_repo":
    command => "echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list",
    creates => "/etc/apt/sources.list.d/elastic-5.x.list",
    require => Exec['apt_key_elastic_co']
}
exec { "apt_upgate_elastic_repo":
    command => "apt-get update 2>&1 > /dev/null",
    creates => "/usr/share/logstash/bin/logstash",
    require => Exec['apt_add_elastic_repo']
}
# used on server box
package {["apt-transport-https", "elasticsearch", "logstash", "kibana"]:
    ensure  => installed,
    require => Exec['apt_upgate_elastic_repo']
}
file {"/etc/elasticsearch/elasticsearch.yml":
    ensure  => file,
    backup  => true,
    owner   => 'root',
    group   => 'elasticsearch',
    mode    => '0640',
    content => template($elasticsearch_conf),
    require => Package['elasticsearch']
}
file {"/etc/elasticsearch/jvm.options":
    ensure  => file,
    backup  => true,
    owner   => 'root',
    group   => 'elasticsearch',
    mode    => '0640',
    content => template($elasticsearch_jvm),
    require => Package['elasticsearch']
}
file {"/etc/kibana/kibana.yml":
    ensure  => file,
    backup  => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0664',
    content => template($kibana_conf),
    require => Package['kibana']
}
service { "kibana":
    ensure  => running,
    enable  => true,
    require => File["/etc/kibana/kibana.yml"],
    subscribe => File["/etc/kibana/kibana.yml"]
}
service { "elasticsearch":
    ensure  => running,
    enable  => true,
    require => File["/etc/elasticsearch/elasticsearch.yml"],
    subscribe => File["/etc/elasticsearch/elasticsearch.yml"]
}
# required on client machine
$filebeat_conf = "core/filebeat.min.yml"
package {["filebeat"]:
    ensure  => installed,
    require => Exec['apt_upgate_elastic_repo']   
}
file {"/etc/filebeat/filebeat.yml":
    ensure  => file,
    backup  => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template($filebeat_conf),
    require => Package['filebeat']
}
service { "filebeat":
    ensure  => running,
    enable  => true,
    require => File["/etc/filebeat/filebeat.yml"],
    subscribe => File["/etc/filebeat/filebeat.yml"]
}
