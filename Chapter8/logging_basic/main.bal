// Run with `bal run`
// Change log level to INFO,WARN, ERROR on Config.toml file and run the application

import ballerina/log;

public function main() {
    log:printDebug("debug log");
    log:printInfo("info log");
    log:printWarn("warn log");
    log:printError("error log");
}
