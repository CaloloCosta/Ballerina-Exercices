import ballerina/log;
import ballerina/http;
import ballerinax/docker;
import ballerina/io;

// Type definition for a remark order
type examPaper record {
    string studentNumber;
    string courseID;
};

// Client endpoint to communicate with student service
http:Client studentMgtEP = new("http://localhost:9091/student-management");
//Client endpoint to communicate with lecturer service 
//NB: ONLY APPLICABLE WHENYOU ARE DONE IMPLEMENTING LECTURER SERVICE
http:Client lecturerMgtEP = new("http://localhost:9092/lecturer-management");

// Service endpoint
listener http:Listener httpListener = new(9090);

// Exam manager service, which is managing remark requests received from the client 
@http:ServiceConfig {
    basePath:"/exam-manager"
}
service ExamManagement on httpListener {
    // Resource that allows users to place an order for a pickup
    @http:ResourceConfig {
        path : "/remark",
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"]
    }
    resource function remarkMngr(http:Caller caller, http:Request request) returns error? {
        http:Response response = new;
        json reqPayload;

        // Try parsing the JSON payload from the request
        var payload = request.getJsonPayload();
        if (payload is json) {
            reqPayload = payload;
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            checkpanic caller->respond(response);
            return;
        }

        json stNo = reqPayload.studentNumber;
        json course = reqPayload.courseID;


        // If payload parsing fails, send a "Bad Request" message as the response
        if (stNo == null || course == null ) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Remark Request payload"});
            checkpanic caller->respond(response);
            return;
        }

        //Details of examp paper to be remarked
        examPaper paperForRemark = {
            studentNumber: stNo.toString(),
            courseID:course.toString()
        };

        log:printInfo("Calling student management service:");

        // call student-management to get student info
        json responseMessage;
        http:Request studentManagerReq = new;
        json remarkjson = check json.convert(paperForRemark);
        studentManagerReq.setJsonPayload(untaint remarkjson);
        http:Response studentResponse=  check studentMgtEP->post("/student-info", studentManagerReq);
        json studentResponseJSON = check studentResponse.getJsonPayload();

        //call lecturer service to get comments and lecturer assigned
        http:Response lecturerResponse =  check lecturerMgtEP ->post("/remarks", studentManagerReq);
        json lres = check lecturerResponse.getJsonPayload();
        json assignedLecturerDetails = check lecturerResponse.getJsonPayload();
        // Dispatch to the distribution service
        // Create a JMS message
        json remarkFullDetails ={"Student Details":studentResponseJSON,"Course and Lecturer info":lres};
        io:println(remarkFullDetails);
        
        // Send response to the user
        responseMessage = {"Message":"Remark information received"};
        response.setJsonPayload(responseMessage);
        checkpanic caller->respond(response);
        return;
    }
}