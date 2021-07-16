// Start Elasticsearch server. (Run `elasticsearch` for HomeBrew)
// Go to the http://localhost:9200 and check elasticsearch up and running

// Start logstash with the following command
`./logstash -e 'input { stdin{} } filter { grok{ match => {  "message" => "time%{SPACE}=%{SPACE}%{TIMESTAMP_ISO8601:date}%{SPACE}level%{SPACE}=%{SPACE}%{WORD:logLevel}%{SPACE}module%{SPACE}=%{SPACE}%{GREEDYDATA:package}%{SPACE}message%{SPACE}=%{SPACE}\"%{GREEDYDATA:logMessage}\"" } } if [logLevel] == "INFO" { mutate { add_field => {"tagType" => "info log"} } } } output { elasticsearch{  hosts => "localhost:9200" index => "order_management_system" document_type => "store_logs" } }'`

// Start Kibana with `./kibana`

// Publish message with the follwing log on logstash
`time = 2021-07-07T14:31:42.982+05:30 level = INFO module = user/logging_basic message = "This is sample info log"`
