// Download logstash from https://www.elastic.co/downloads/logstash
// Start logstash with the following command
`./logstash -e 'input { stdin { } } output { stdout {} }'`
// Type value in terminal and it return the result.

// Start logstash with the following command
`./logstash -e 'input { stdin{} } filter { grok{ match => {  "message" => "time%{SPACE}=%{SPACE}%{TIMESTAMP_ISO8601:date}%{SPACE}level%{SPACE}=%{SPACE}%{WORD:logLevel}%{SPACE}module%{SPACE}=%{SPACE}%{GREEDYDATA:package}%{SPACE}message%{SPACE}=%{SPACE}\"%{GREEDYDATA:logMessage}\"" } } } output { stdout {} }'`
// Try to parse the following input
`time = 2021-07-07T14:31:42.982+05:30 level = INFO module = user/logging_basic message = "This is sample info log"`

// Start logstash with the following command
`./logstash -e 'input { stdin{} } filter { grok{ match => {  "message" => "time%{SPACE}=%{SPACE}%{TIMESTAMP_ISO8601:date}%{SPACE}level%{SPACE}=%{SPACE}%{WORD:logLevel}%{SPACE}module%{SPACE}=%{SPACE}%{GREEDYDATA:package}%{SPACE}message%{SPACE}=%{SPACE}\"%{GREEDYDATA:logMessage}\"" } } if [logLevel] == "INFO" { mutate { add_field => {"tagType" => "info log"} } } } output { stdout {} }'`
// Try to parse the following input
`time = 2021-07-07T14:31:42.982+05:30 level = INFO module = user/logging_basic message = "This is sample info log"`

// Use the following command to write logs to a file
`bal run logging_basic/  2> logging_basic.log`
