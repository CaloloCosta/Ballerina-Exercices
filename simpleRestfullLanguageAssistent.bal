// In this problem, we wish to use the service construct in Ballerina to implement a multi-lingual greeting
// assistant. A client issues a language code (EN, FR, GE) and receives a greeting back in the desired
// language. To do so, a greeting assistant service enlists language specific services English assistant, French
// assistant and German assistant. Depending on the code sent by the client, the corresponding language
// assistant is called upon. All services should be implemented as an independent endpoint. The client should
// communicate with the greeting assistant using the HTTP2 protocol. All other communications can follow
// the HTTP (1.1) protocol. The overall system should be deployed using the Docker container.


import ballerina/http;
import ballerina/log;
import ballerina/io;

listener http:Listener http2Listener = new (9090, config = {httpVersion: "2.0"});

function sendRequest(http:Caller caller, string servicePath, string assistentPath){
    http:Client clientEP = new (servicePath);
    var res = clientEP->get(assistentPath);
    if(res is http:Response){
        var payload = res.getTextPayload();
        if(payload is string){
            http:Response response = new;    
            response.setTextPayload(untaint payload);
            error? result = caller -> respond(response);
        }            
    }
    else{
        io:println(<string> res.detail().message);
    }
}

@http:ServiceConfig {
    basePath: "/" 
}
service greetingAssistent on  http2Listener{

    resource function EN(http:Caller caller, http:Request request){
        sendRequest(caller,"http://localhost:3000","/EnglishAssistent/");
    }

    resource function GN(http:Caller caller, http:Request request){
        sendRequest(caller,"http://localhost:3000","/GermanAssistent/");
    }
    
    resource function WA(http:Caller caller, http:Request request){
        sendRequest(caller, "http://localhost:3000","/WamboAssistent");

    }

    resource function NG(http:Caller caller, http:Request request){
        sendRequest(caller,"http://localhost:3000","/NganguelaAssistent");
    }

}

listener http:Listener http = new(3000);

service EnglishAssistent on http{
    @http:ResourceConfig {
        path: "/"
    }
    resource function speak(http:Caller caller, http:Request request){
        http:Response response = new;
        response.setTextPayload("Good morning, how are you?\nI'm doing fine.\nCan you please assist me with some water?\nThank you very much!!");
        error? result = caller -> respond(response);
        if(result is error){
            log:printError("Error ", err = result);
        }
    }
}

service GermanAssistent on http{
    @http:ResourceConfig {
        path: "/"
    }
    resource function speak(http:Caller caller, http:Request request){
        http:Response response = new;
        response.setTextPayload("Guten Morgen, wie geht es dir?\nIch bin wohlauf.\nKonnen Sie mir bitte etwas Wasser geben?\nVielen Dank!!");
        error? result = caller -> respond(response);
        if(result is error){
            log:printError("Error ", err = result);
        }
    }
}

service WamboAssistent on http{
    @http:ResourceConfig{
        path: "/"
    }
    resource function speak(http:Caller caller, http:Request request){
        http:Response response = new;
        response.setTextPayload("Walelepo\nOnawa.\nAlikana kwafelange omeya?\nTangi unene");
        error? result = caller -> respond(response);
        if( result is error){
            log:printError("Error ",err = result);
        }
    }
}

service NganguelaAssistent on http{
    @http:ResourceConfig{
        path:"/"
    }
    resource function speak(http:Caller caller, http:Request request){
        http:Response response = new;
        response.setTextPayload("Cimene ca cili, vati uli?\nNdjili mua cili\nCiltava u ndji hane mema?\nNdji na sakuila");
        error? result = caller -> respond(response);
        if( result is error){
            log:printError("Error ",err = result);
        }
    }
    
}
