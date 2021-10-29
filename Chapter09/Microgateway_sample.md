Run backend service with `bal run HelloWorld`
Build micro-gateway with `micro-gw build oms_gateway/` command
Start gateway with `gateway oms_gateway/target/oms_gateway.jar`
Get a key with the following curl command
curl -X get "https://localhost:9095/apikey" -H "Authorization:Basic YWRtaW46YWRtaW4=" -k
Invoke the API with the following curl command
curl -X GET "https://localhost:9095/hello/sayHello?foo=foo" -H "Authorization:Bearer <token>" -k 

