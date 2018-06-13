Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
# include elk
$elasticsearch_cluster_name = "elk"
$elasticsearch_server_ip    = "127.0.0.1"
$elasticsearch_server_port  = 9200
$elasticsearch_jvm          = "core/jvm.min.options"
$elasticsearch_conf         = "core/elasticsearch.min.yml"
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