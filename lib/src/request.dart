import "dart:async";

import "package:http/http.dart" as http;
import "coffee.dart";
import "middleware.dart";
import 'response.dart';

class CoffeeHttpRequest extends CoffeeRequester {
  final String method;
  final Map<String, String> headers;
  String url;

  final Function decoder;
  final Function encoder;

  CoffeeRequester requester;

  CoffeeHttpRequest(this.url,
      {this.method: GetMethod,
      this.headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeHttpRequest> requests,
      http.Client client,
      this.decoder,
      this.encoder})
      : super(middlewares: middlewares, requests: requests, client: client) {
    requests?.forEach((_, CoffeeHttpRequest request) {
      configureRequest(request);
      request.url = url + request.url;
    });
    if (requests == null) {
      requests = {};
    }
  }

  @override
  CoffeeHttpRequest operator [](String name) {
    CoffeeHttpRequest request = requests.containsKey(name) ? requests[name] : null;

    if (request != null) {
      request.requester = this.requester;
    }
    return request;
  }

  @override
  void operator []=(String name, CoffeeHttpRequest request) {
    request.url = url + request.url;
    super[name] = request;
  }

  Future<CoffeeResponse> execute(
      {dynamic body, Map<String, dynamic> queryParameters, Map<String, dynamic> parameters}) {
    return coffee(this, body: body, queryParameters: queryParameters, parameters: parameters);
  }
}

class CoffeeRequest {
  final CoffeeHttpRequest config;
  String method;
  String url;
  Map<String, String> headers;
  dynamic body;

  CoffeeRequest(this.config, this.body) {
    method = config.method;
    url = this.config.url;
    headers = this.config.headers ?? {};
  }
}

class Get extends CoffeeHttpRequest {
  Get(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeHttpRequest> requests,
      dynamic decoder(dynamic body)})
      : super(url,
            method: GetMethod,
            headers: headers,
            middlewares: middlewares,
            requests: requests,
            decoder: decoder);
}

class Post extends CoffeeHttpRequest {
  Post(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeHttpRequest> requests,
      dynamic decoder(dynamic body),
      dynamic encoder(dynamic body)})
      : super(url,
            method: PostMethod,
            headers: headers,
            middlewares: middlewares,
            requests: requests,
            decoder: decoder,
            encoder: encoder);
}

class Put extends CoffeeHttpRequest {
  Put(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeHttpRequest> requests,
      dynamic decoder(dynamic body),
      dynamic encoder(dynamic body)})
      : super(url,
            method: PutMethod,
            headers: headers,
            middlewares: middlewares,
            requests: requests,
            decoder: decoder,
            encoder: encoder);
}

class Delete extends CoffeeHttpRequest {
  Delete(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeHttpRequest> requests,
      dynamic decoder(dynamic body)})
      : super(url,
            method: DeleteMethod,
            headers: headers,
            middlewares: middlewares,
            requests: requests,
            decoder: decoder);
}
