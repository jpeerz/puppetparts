### Getting started with a Log Aggregator

What's the problem with logs ?

- different systems/locations
- different sources/paths
- various formats

> infrastructure sample

Working with plain text files

+ noise - debug level
+ disk usage - rotation + retain policy

Use cases

* Which node is causing the service outage ?
* What's happening right before that exception ?

The Goal

* Collect
* Index & Search
* Visualize
* Security (transfering access logs)
* Shard

Solutions from market

* FluentD
    + Log are stored to fs buffer when net down
    - difficult to setup
* Sentry
    + opensource with hosted version
    - just a collector of exceptions
* Logentries
    + real time alerts
    - confusing interface
* Logstash
    + opensource
    - no bundled UI

### Jumping into ELK

Create fresh machine

    aws cloudformation create-stack \
    --stack-name xenialelasticsearch \
    --template-body file://`pwd`/ubuntu_xenial_elk.cf.json \
    --parameters file://`pwd`/ubuntu_xenial_base.parameters.cf.json

    aws cloudformation create-stack \
    --stack-name xenialkibana \
    --template-body file://`pwd`/ubuntu_xenial_elk.cf.json \
    --parameters file://`pwd`/ubuntu_xenial_base.parameters.cf.json

> view **ELK components the big picture**

ssh -i ~/.ssh/webadmin.pem ubuntu@ec2-54-200-150-108.us-west-2.compute.amazonaws.com

ssh -i ~/.ssh/webadmin.pem ubuntu@ec2-54-218-122-25.us-west-2.compute.amazonaws.com

Install IaC software

    sudo su
    apt update && apt install -y puppet git-core && git clone https://github.com/jpeerz/puppetparts.git /opt/puppetparts && cp /opt/puppetparts/puppet/modules/core/files/puppet.conf /etc/puppet/puppet.conf

Provision machines with puppet

Deploy Java

    puppet apply --environment localhost --modulepath /opt/puppetparts/puppet/modules:/etc/puppet/modules /opt/puppetparts/puppet/modules/core/manifests/java.pp

Deploy ELK
172.31.17.3
172.31.24.222
    vi /opt/puppetparts/puppet/modules/core/manifests/elasticsearch.pp
    vi /opt/puppetparts/puppet/modules/core/manifests/filebeat.pp
    puppet apply --environment localhost --modulepath /opt/puppetparts/puppet/modules:/etc/puppet/modules /opt/puppetparts/puppet/modules/core/manifests/elasticsearch.pp
    puppet apply --environment localhost --modulepath /opt/puppetparts/puppet/modules:/etc/puppet/modules /opt/puppetparts/puppet/modules/core/manifests/filebeat.pp

    vi /opt/puppetparts/puppet/modules/core/manifests/kibana.pp
    puppet apply --environment localhost --modulepath /opt/puppetparts/puppet/modules:/etc/puppet/modules /opt/puppetparts/puppet/modules/core/manifests/kibana.pp

Test ElasticSearch running

    curl http://172.31.24.222:9200/_cat/indices?v&pretty

    ssh -L 9200:172.31.24.222:9200 -L 5601:172.31.17.3:5601 -i ~/.ssh/webadmin.pem ubuntu@ec2-54-200-150-108.us-west-2.compute.amazonaws.com

    curl "http://172.31.24.222:9200/_cat/indices?v&pretty"

Browse Kibana UI

    http://localhost:5601/

Add discover pattern

Search in [Kibana Console](https://www.elastic.co/guide/en/kibana/5.6/console-kibana.html)

    GET /_search
    {
    "query": { 
        "bool": { 
        "must": [
            { "match": { "message": "Client not found: APP-7DBPOUGUYZ828WVZ" }}  
        ]
        }
    }
    }
GET filebeat-2018.06.13/_search 
{
    "query": { 
        "bool": { 
        "must": [
            { "match": { "message": "update_mapping" }}  
        ]
        }
    }
}


Search from cmd line via REST

    curl -X GET "http://172.31.17.188:9200/_search" -H 'Content-Type: application/json' -d'
    {
    "query": { 
        "bool": { 
        "must": [
            { "match": { "message": "Client not found: APP-7DBPOUGUYZ828WVZ" }}  
        ]
        }
    }
    }'

[More about Elasticsearch DSL](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/query-dsl.html)

    curl -X GET "localhost:9200/_search" -H 'Content-Type: application/json' -d'
    {
    "query": { 
        "bool": { 
        "must": [
            { "match": { "title":   "Search"        }}, 
            { "match": { "content": "Elasticsearch" }}  
        ],
        "filter": [ 
            { "term":  { "status": "published" }}, 
            { "range": { "publish_date": { "gte": "2015-01-01" }}} 
        ]
        }
    }
    }
    '

https://www.elastic.co/guide/en/kibana/5.6/field-filter.html

https://www.elastic.co/guide/en/elasticsearch/reference/6.3/query-dsl-match-query.html

https://www.elastic.co/guide/en/beats/packetbeat/current/load-kibana-dashboards.html
