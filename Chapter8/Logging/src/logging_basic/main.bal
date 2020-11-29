
import ballerina/log;
import ballerina/runtime;
public function main() {
    error err = error("something went wrong!");
    log:printTrace("trace log");
    log:printDebug("debug log");
    log:printInfo("info log");
    log:printWarn("warn log");
    log:printError("error log");
    

    log:printInfo(function() returns string {
        return string `Current stack trace: ${runtime:getCallStack().toString()}`;
    });
}