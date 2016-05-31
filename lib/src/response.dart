import "package:http/http.dart" as http;

import "request.dart";

class CoffeeResponse extends http.Response {
    dynamic decodedBody;

    CoffeeHttpRequest baseRequest;

    CoffeeResponse(http.Response response, this.baseRequest)
        : super(response.body, response.statusCode,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);

    CoffeeResponse.Error(this.baseRequest, int statusCode, String message) : super(message, statusCode,
        reasonPhrase: message);

    bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}