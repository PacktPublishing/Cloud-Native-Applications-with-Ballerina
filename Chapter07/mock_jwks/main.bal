import ballerina/http;

listener http:Listener oauth2Server = new (20000);
service /oauth2 on oauth2Server {
    resource function get jwks() returns json {
        json jwks = {
            "keys": [
                    {
                        "kty": "RSA",
                        "e": "AQAB",
                        "use": "sig",
                        "kid": "MzMxM2UxNDUyZDg3MTQ1YjM0MzEzODI0YWI4NDNlZDU1ODQzZWFjMQ==",
                        "alg": "RS256",
                        "n": "poN-nQHxxWpW7-AgTUZjmY6yaN1Ghbn-xeaz6TEAGz76cci9a2twU58FLHYwTBk0vWoZODVOGf5pYc_VIKouTkJQ-CvUPIdmxMO6L_k5Z8dt0wbxdRm1VPkTr3vg_Y8c6svPqtanaf36C-iwRTT5NkWE6dHbovSOJuS86kl6dcyS5_gAYQXKXUm8J3LHpIA3lYnKetDHhDNE0vRY3I2q8uD09pHzhrtHFz60pYfiMMNCIe1NgSKXBJ8HoeTdK808JW1LT0RMXqNY9yHaq-W0I9dSF1guC_aqQ6WzrGCKvUq2aK2CCdPNa3efs7p0RIzmrLCNLonzuA_aGTAc04zbJQ"
                    }
                ]
        };
        return jwks;
    }
}