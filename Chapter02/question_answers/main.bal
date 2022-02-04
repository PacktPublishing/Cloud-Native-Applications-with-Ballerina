// ----Ballerina answers for questions -------
// Run this sample with `bal run question_answers/` command

import ballerina/io;

public function main() {
    //--- Answer for Q1
    int rows = 10; 
    foreach int i in 1..< rows { 
        foreach int j in i..< rows { 
            io:print(" "); 
        } 
        foreach int k in 1..< 2*i-1 { 
            io:print("*"); 
        } 
        io:println(""); 
    }
    //--- Answer for Q2
    int[] values = [5, 3, 9, 2, 4]; 
    int element = 0; 
    int j = 0;  
    foreach int i in 1..< values.length() { 
        element = values[i]; j = i - 1;  
        while (j >= 0 && values[j] > element) {  
            values[j + 1] = values[j];  
            j = j - 1;  
        }  
        values[j + 1] = element;  
    } 
}
