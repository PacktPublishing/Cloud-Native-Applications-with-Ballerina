// Download Filebeat with `docker pull docker.elastic.co/beats/filebeat:7.13.3` command

// Start Logstash with following command
`./logstash -e 'input { beats { port => 5044 } } filter { grok{ match => {  "message" => "time%{SPACE}=%{SPACE}%{TIMESTAMP_ISO8601:date}%{SPACE}level%{SPACE}=%{SPACE}%{WORD:logLevel}%{SPACE}module%{SPACE}=%{SPACE}%{GREEDYDATA:package}%{SPACE}message%{SPACE}=%{SPACE}\"%{GREEDYDATA:logMessage}\"" } } } output { stdout {} }'`

// Get the IP address of the host computer

// Create filebeat.yml with the following content
```
filebeat.inputs: 
- type: log 
  paths: 
    - /usr/share/filebeat/logging_basic.log
output.logstash: 
  hosts: ["192.168.43.212:5044"]
```

// Start File beat with the following Docker command
`docker run --volume="/Users/dhanushka/Desktop/ballerina/filebeat.yml:/usr/share/filebeat/filebeat.yml" --volume="/Users/dhanushka/Desktop/ballerina/logging_basic.log:/usr/share/filebeat/logging_basic.log" docker.elastic.co/beats/filebeat:7.13.3`

// Use the following command to write logs to a file
`bal run logging_basic/  2> /Users/dhanushka/Desktop/ballerina/logging_basic.log`