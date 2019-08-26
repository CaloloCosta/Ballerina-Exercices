import ballerina/http;
import ballerina/log;
import ballerina/io;

type Student record {
    string name;
    string address;
    string phonenumber;
    string studentNumber;
    string email;
    int yearOfStudy;
};
Student st1 ={
    name: "Jesicca Miyano",
    address: "Erf 223, Jackson Rd, Windhoek",
    phonenumber: "0852344182",
    studentNumber: "232323",
    email: "jmiyano@ballerina.io",
    yearOfStudy:2
};
Student st2 ={
    name: "Obby Kwenani",
    address: "House 98, R.Mugabe Rd, Windhoek",
    phonenumber: "0813242457",
    studentNumber: "242424",
    email: "okwenani@ballerina.io",
    yearOfStudy:3
};
map <Student> registeredStudents = {"232323":st1,"242424":st2};

listener http:Listener httpListener = new(9091);


@http:ServiceConfig {
    basePath: "/student-management"
}
service PassengerManagement on httpListener {
    @http:ResourceConfig {
        path : "/student-info",
        methods : ["POST"]
    }
    resource function info(http:Caller caller, http:Request request) returns error? {
        // create an empty response object
        http:Response res = new;
        
        // check will cause the service to send back an error 
        // if the payload is not JSON
        json responseMessage;
        json studentInfoJSON = check request.getJsonPayload();

        log:printInfo("JSON :::" + studentInfoJSON.toString());

        string stNo = studentInfoJSON.studentNumber.toString();
        string courseID = studentInfoJSON.courseID.toString();

        any|error responseOutcome;
        if(registeredStudents.hasKey(stNo)){
            json student = check json.convert(registeredStudents[stNo]);
            Student reqStudent = {
            name: student.name.toString(),
            address: student.address.toString(),
            phonenumber: student.phonenumber.toString(),
            studentNumber:student.studentNumber.toString(),
            email: student.email.toString(),
            yearOfStudy:<int>student.yearOfStudy
            };
            json details =   check (json.convert(reqStudent));
            log:printInfo("Student details:" + details.toString());


            json studentjson = check json.convert(reqStudent);
            responseMessage = {"student":studentjson};
            io:println("Student details");
            io:println(studentjson);
            log:printInfo("All details included in the response:" + studentjson.toString());
            res.setJsonPayload(untaint responseMessage);
            responseOutcome = caller->respond(res);

        }else{
            responseMessage = {"message":"Error:No valid student number provided"};
            res.setJsonPayload(untaint responseMessage);
            io:println(responseMessage);
            responseOutcome = caller->respond(res);
        }

        return;
    }
}