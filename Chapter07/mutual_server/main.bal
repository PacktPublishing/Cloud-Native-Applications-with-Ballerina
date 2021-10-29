// Generate server side certificates with the following command
// `keytool -genkeypair -alias ballerina -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore ballerinaKeystoreServer.p12 -validity 3650`
// CN=localhost, OU=ballerina, O=ballerina, L=Colombo, ST=Western, C=LK
// `openssl pkcs12 -in ballerinaKeystoreServer.p12 -nokeys -out ballerinaServer.crt`
// `openssl pkcs12 -in ballerinaKeystoreServer.p12  -nodes -nocerts -out ballerinaServer.key`

// Generate client side certificates with the following commands
// `keytool -genkeypair -alias ballerinaClient -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore ballerinaKeystoreClient.p12 -validity 3650`
// `openssl pkcs12 -in ballerinaKeystoreClient.p12 -nokeys -out ballerinaClient.crt`
// `openssl pkcs12 -in ballerinaKeystoreClient.p12  -nodes -nocerts -out ballerinaClient.key`

// Run project with `bal run mutual_server/`
// Follow instructions in mutual_client example
import ballerina/http;
http:ListenerConfiguration mutualSSLServiceEPConfig = { 
    secureSocket: {
        key: {
            certFile: "resources2/ballerinaServer.crt",
            keyFile: "resources2/ballerinaServer.key"
        },
        mutualSsl: {
            verifyClient: http:REQUIRE,
            cert: "resources2/ballerinaClient.crt"
        },
        protocol: {
            name: http:TLS,
            versions: ["TLSv1.2", "TLSv1.1"]
        },
        ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"]

    }
};
listener http:Listener serviceEP = new (9093, mutualSSLServiceEPConfig); 
service /testMutualSSL on serviceEP {
    resource function get .() returns string {
        return "Hello, World!";
    }
}