// `keytool -genkeypair -alias ballerina -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore ballerinaKeystore.p12 -validity 3650`
// CN=localhost, OU=ballerina, O=ballerina, L=Colombo, ST=Western, C=LK
// `openssl pkcs12 -in ballerinaKeystore.p12 -nokeys -out ballerinaServer.crt`
// `openssl pkcs12 -in ballerinaKeystore.p12  -nodes -nocerts -out ballerinaServer.key`

// Start the service with `bal run https_server/`
// Go to browser with the link `https://localhost:9093/testHTTPS`


import ballerina/http;
http:ListenerConfiguration epConfig = {
    secureSocket: {
        key: {
            certFile: "resources/ballerinaServer.crt",
            keyFile: "resources/ballerinaServer.key"
        }
    }
};
listener http:Listener httpsListener = new (9093, epConfig);

service /testHTTPS on httpsListener {
    resource function get .(http:Caller caller, http:Request req) returns error?{
        _ = check caller->respond("Hello World!");
    }
}