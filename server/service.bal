// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content

import ballerina/http;
import gramaCheck.types;
import gramaCheck.database;
import gramaCheck.constants;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],

        allowCredentials: false,
        allowHeaders: ["CORELATION_ID", "authorization", "Access-Control-Allow-Origin", "Content-Type", "SOAPAction", "apikey", "Internal-Key"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        allowMethods: ["GET", "PUT", "POST", "DELETE", "PATCH", "OPTIONS"],
        maxAge: 84900
    }
}

service /requestService on new http:Listener(9091) {

    isolated resource function post request(@http:Payload types:Request request)
    returns types:AppSuccess|types:AppServerError {
        types:ExecutionSuccessResult|error result = database:addRequest(request);
        if result is error {
            return <types:AppServerError>{
                body: {
                    message: constants:CANNOT_ADD_ENTRY
                }
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

isolated resource function get request/[int requestId]()
returns types:Request|types:AppServerError|types:AppNotFoundError {
        types:Request|error? result = database:getRequest(requestId);
        if result is () {
            return <types:AppNotFoundError>{
                body: {
                    message: constants:ID_NOT_FOUND
                }
            };
        }
        if result is error {
            return <types:AppServerError>{
                body: {
                    message: constants:CANNOT_RETRIEVE_FROM_DB
                }
            };
        }
        return result;
    }
}

service /Identity on new http:Listener(9090) {
    isolated resource function get identity/[string nicNumber]()
        returns boolean|types:AppServerError{
        boolean|error result = database:getIdentity(nicNumber);
        if result is error {
            return <types:AppServerError>{
                body: {
                    message: constants:IDENTYTIY_CHECK_FAILED
                }
            };
        }
        return result;
    }
}

service /addressCheck on new http:Listener(9092) {
    isolated resource function get address/[string nic]/[string houseNo]/[string street]/[string city]/[string district]/[string province]()
        returns boolean|types:AppServerError {
        boolean|error result = database:getAddress(nic, houseNo, street, city, district, province);
        if result is error {
            return <types:AppServerError>{
                body: {
                    message: constants:ADDRESS_CHECK_FAILED
                }
            };
        }
        return result;
    }
}
