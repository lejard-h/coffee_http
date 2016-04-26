/**
 * Created by lejard_h on 25/04/16.
 */

part of coffee;

class CoffeeResponse extends http.Response {
  var decodedBody;

  CoffeeHttpRequest baseRequest;

  CoffeeResponse(http.Response response, this.baseRequest)
      : super(response.body, response.statusCode,
            request: response.request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase);
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
      dynamic decoder(dynamic)})
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
      dynamic decoder(dynamic),
      dynamic encoder(dynamic)})
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
      dynamic decoder(dynamic),
      dynamic encoder(dynamic)})
      : super(url,
            method: PostMethod,
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
      dynamic decoder(dynamic)})
      : super(url,
            method: GetMethod,
            headers: headers,
            middlewares: middlewares,
            requests: requests,
            decoder: decoder);
}

class _Requester {
  http.Client client;

  _Requester(this.client);

  Future<CoffeeResponse> get(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.get(request.url, headers: request.headers),
          request.config);
    }
    return new CoffeeResponse(
        await client.get(request.url, headers: request.headers),
        request.config);
  }

  Future<CoffeeResponse> post(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.post(request.url,
              headers: request.headers, body: request.body),
          request.config);
    }
    return new CoffeeResponse(
        await client.post(request.url,
            headers: request.headers, body: request.body),
        request.config);
  }

  Future<CoffeeResponse> put(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.put(request.url,
              headers: request.headers, body: request.body),
          request.config);
    }
    return new CoffeeResponse(
        await client.put(request.url,
            headers: request.headers, body: request.body),
        request.config);
  }

  Future<CoffeeResponse> patch(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.patch(request.url,
              headers: request.headers, body: request.body),
          request.config);
    }
    return new CoffeeResponse(
        await client.patch(request.url,
            headers: request.headers, body: request.body),
        request.config);
  }

  Future<CoffeeResponse> delete(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.delete(request.url, headers: request.headers),
          request.config);
    }
    return new CoffeeResponse(
        await client.delete(request.url, headers: request.headers),
        request.config);
  }

  Future<CoffeeResponse> head(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.head(request.url, headers: request.headers),
          request.config);
    }
    return new CoffeeResponse(
        await client.head(request.url, headers: request.headers),
        request.config);
  }
}
