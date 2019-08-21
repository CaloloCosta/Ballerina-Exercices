// Create a Ballerina program that randomly picks two number between 1 and 200 and then computes 
// the prime numbers in between the selected number. 
// Finally, the program should print the output as follows: 
// {”the small number is” : value, ”the big number is” : value, ”prime numbers in range” : [{prime i : value}, {prime j: value}, . . .]}

import ballerina/math;
import ballerina/io;

public function main(){
    int n1 = math:randomInRange(1,201);
    int n2 = math:randomInRange(1, 201);

    // checking if n1 is greater than n1
    if(n1 > n2){
        int aux;
        aux = n1;
        n1 = n2;
        n2 = aux;
    }

    json result = {
        "the small number is ": (n1 < n2)?n1:n2,
        "the big number is ": (n1 > n2)?n1:n2,
        "prime numbers in range ": []
    };

    json prime = [];

    int count = 0;
    int pc = 1;
    foreach var i in n1...n2 {
        foreach var a in 1...i{
            if(i % a == 0){
                count += 1;
            }
        }
        if(count == 2){
            prime[pc-1] = {"prime "+pc: i};
            pc += 1;
        }
        count = 0;
        
    }

    result["prime numbers in range "] = prime;

    io:println("\n",result, "\n");
}
