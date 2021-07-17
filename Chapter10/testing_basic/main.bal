// Run test with `bal test`
// Run only single test with `bal test --tests testAssertEquals`
// Run tests in given module with `bal test --tests testing_basic.basic_module:*`
// Generate test report with `bal test --test-report`
// Generate code coverage JSON with `bal test --code-coverage`
// Get both test report and code coverage with `bal test --test-report --code-coverage`
// Run only groups A testcases with `bal test --groups GroupA`
// Run both GroupA and GroupB testcases `bal test --groups GroupA,GroupB`

import ballerina/io;

public function main() {
    io:println("Hello World!");
}
public function sum(int a, int b) returns int{
    return a + b;
}
