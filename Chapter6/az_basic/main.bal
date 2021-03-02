
import ballerinax/azure_functions as af;

@af:Function
public function hello(@af:HTTPTrigger { authLevel: "anonymous" } string input) 
                      returns @af:HTTPOutput string|error {
    return "Response from lambda, " + input;
}