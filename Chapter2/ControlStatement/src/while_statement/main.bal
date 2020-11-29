import ballerina/io;

public function main() {
    int index = 0;
    while index <= 10 {
        io:print(index.toString() + " ");
        index = index + 1;
    }
}
