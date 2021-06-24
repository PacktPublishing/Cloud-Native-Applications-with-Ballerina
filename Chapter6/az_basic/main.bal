
// create resource group on Azure portal. ex: BallerinaGroup
// create a function app on Azure portal. ex: ballerinaapp
// Build the project with `bal build az_basic/`
// Deploy the function with following command
// `az functionapp deployment source config-zip -g BallerinaGroup -n ballerinaapp --src az_basic/target/bin/azure-functions.zip`
// Test the endpoint with curl command `curl -d "Hello World" https://ballerinaapp.azurewebsites.net/api/hello`
import ballerinax/azure_functions as af;

@af:Function
public function hello(@af:HTTPTrigger { authLevel: "anonymous" } string input) 
                      returns @af:HTTPOutput string|error {
    return "Response from Azure, " + input;
}