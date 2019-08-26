import ballerina/io;
import ballerina/http;


// course record
type Course record  {
    string name;
    int credit;
    int semester;
};

// lecturer record
type Lecturer record {
    string name;
    string department;
};

Course c1 = {
    name: "Programming one",
    credit: 50,
    semester: 1
};
Course c2 = {
    name: "Comuter Organization and Archtecture",
    credit: 50,
    semester: 1
};
Lecturer l1 = {
    name: "Kandjimi",
    department: "Computer Science"
};

Lecturer l2 = {
    name: "Edward",
    department: "Computer Science"
};

type Details record{
    Lecturer ld;
    Course cd;
};

map <Course> course = {"PRG1": c1,"COA": c2};
map <Lecturer> lecturer = {"PRG1": l1, "COA": l2};


@http:ServiceConfig {
    basePath:"/lecturer-management"
}
service lecturerService on new http:Listener(9092){
    @http:ResourceConfig{
        path: "/remarks",
        methods: ["POST"]
    }
    resource function lectREsource(http:Caller caller, http:Request request){
        var payload = request.getJsonPayload();
            //         Student reqStudent = {
            // name: student.name.toString(),
            // address: student.address.toString(),
            // phonenumber: student.phonenumber.toString(),
            // studentNumber:student.studentNumber.toString(),
            // email: student.email.toString(),
            // yearOfStudy:<int>student.yearOfStudy
            // };

        if(payload is json){
            string courseCode = payload.courseID.toString();

            map<any> data = {
                "lecturer": lecturer[courseCode],
                "course": course[courseCode]
            };
            json|error res =  json.convert(data);
            if(res is json){
                http:Response response = new;
                response.setJsonPayload(res, contentType="application/json");
                checkpanic caller->respond(response);
            }
        }

    }
}
