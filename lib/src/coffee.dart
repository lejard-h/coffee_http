library coffee.base;

import "dart:async";

import "package:http/http.dart" as http;

import "middleware.dart";
import "request.dart";
import 'response.dart';
import "utils.dart";

const String GetMethod = "Get";
const String PostMethod = "Post";
const String PutMethod = "Put";
const String DeleteMethod = "Delete";
const String PatchMethod = "Patch";
const String HeadMethod = "Head";

class CoffeeRequester {
  List<CoffeeMiddleware> middlewares;
  Map<String, CoffeeHttpRequest> requests;
  http.Client client;

  CoffeeRequester.create();

  CoffeeRequester({this.middlewares, this.requests, this.client}) {
    requests?.forEach((_, CoffeeHttpRequest request) {
      configureRequest(request);
    });
    if (requests == null) {
      requests = {};
    }
  }

  CoffeeHttpRequest operator [](String name) {
    CoffeeHttpRequest request = requests.containsKey(name) ? requests[name] : null;

    if (request != null) {
      request.requester = this;
    }
    return request;
  }

  void operator []=(String name, CoffeeHttpRequest request) {
    configureRequest(request);
    if (requests == null) {
      requests = {};
    }
    requests[name] = request;
  }

  void configureRequest(CoffeeHttpRequest request) {
    request.client = this.client;
    request.requester = this;
  }
}

Future<CoffeeResponse> coffee(CoffeeHttpRequest request,
    {dynamic body, Map<String, dynamic> queryParameters, Map<String, dynamic> parameters}) async {
  CoffeeRequest _request = new CoffeeRequest(request, body);

  if (request.encoder != null) {
    _request.body = request.encoder(_request.body);
  }

  replaceParameters(_request, parameters);
  addQueryParameters(_request, queryParameters);

  preMiddleware(_request);

  CoffeeResponse res = await doRequest(_request);

  postMiddleware(res);
  if (request.decoder != null) {
    res.decodedBody = request.decoder(res.decodedBody);
  }

  return res;
}

http.Client sharedClient;
