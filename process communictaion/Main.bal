import ballerina/io;
import ballerina/http;
import ballerina/log;

http:Client examMgtEP = new("http://localhost:9090/exam-manager");

public function main(string... args) {
    http:Request res = new;
    string stNo = io:readln("Enter student number:");
    string courseId = io:readln("Enter course id for remarking:");

    //setting the content type to be sent
    var x = res.setContentType("application/json");
    json remarkinfo = {"studentNumber":stNo,"courseID":courseId};
    res.setJsonPayload(remarkinfo, contentType = "application/json");
    //send a request to the exam service and check response 
    http:Response examResponse =  checkpanic examMgtEP->post("/remark", res);
    
    var payload = examResponse.getJsonPayload();
    if payload is json{
        //ßprint out results from service
        io:println(payload.toString());
    }

}
