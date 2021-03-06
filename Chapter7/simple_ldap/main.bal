// Start LDAP server with ldapdef.ldif definition
// Start the server with `bal run simple_ldap/` command
// Try to invoke with delivery credentials `curl -X GET http://localhost:9090/oms/deliveryAccess -H 'authorization: Basic ZGVsaXZlcnk6ZGVsaXZlcnk='`
// Try to invoke with customer that response 403 `curl -v -X GET  http://localhost:9090/oms/deliveryAccess -H 'authorization: Basic Y3VzdG9tZXI6Y3VzdG9tZXI='`
// Follow instructions in basic_auth sample
import ballerina/http;
import ballerina/auth;
listener http:Listener securedEP = new(9090);
auth:LdapUserStoreConfig ldapAuthProviderConfig = {
                domainName: "ballerina.io",
                connectionUrl: "ldap://localhost:10389",
                connectionName: "uid=admin,ou=system",
                connectionPassword: "secret",
                userSearchBase: "ou=Users,dc=ballerina,dc=io",
                userEntryObjectClass: "identityPerson",
                userNameAttribute: "uid",
                userNameSearchFilter: "(&(objectClass=person)(uid=?))",
                userNameListFilter: "(objectClass=person)",
                groupSearchBase: ["ou=Groups,dc=ballerina,dc=io"],
                groupEntryObjectClass: "groupOfNames",
                groupNameAttribute: "cn",
                groupNameSearchFilter: "(&(objectClass=groupOfNames)(cn=?))",
                groupNameListFilter: "(objectClass=groupOfNames)",
                membershipAttribute: "member",
                userRolesCacheEnabled: true,
                connectionPoolingEnabled: false,
                connectionTimeout: 5,
                readTimeout: 60
};
@http:ServiceConfig {
    auth: [
        {
            ldapUserStoreConfig: ldapAuthProviderConfig
        }
    ]
}
service /oms on securedEP {
    @http:ResourceConfig {
        auth: [
        {
            ldapUserStoreConfig: ldapAuthProviderConfig,
            scopes: ["delivery"]
        }
        ]
    }
    resource function get deliveryAccess() returns string {
        return "Hello, Delivery!";
    }

    @http:ResourceConfig {
        auth: [
        {
            ldapUserStoreConfig: ldapAuthProviderConfig,
            scopes: ["customer"]
        }
        ]
    }
    resource function get customerAccess() returns string {
        return "Hello, Customer!";
    }
    
}