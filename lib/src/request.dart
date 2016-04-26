/**
 * Created by lejard_h on 25/04/16.
 */

part of coffee;

class CoffeeResponse extends http.Response {
  var decodedBody;

  CoffeeRequester baseRequest;

  CoffeeResponse(http.Response response, this.baseRequest)
      : super(response.body, response.statusCode,
            request: response.request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase);
}

class CoffeeRequest {
  final CoffeeRequester request;
  String method;
  String url;
  Map<String, String> headers;
  dynamic body;

  CoffeeRequest(this.request, this.body) {
    method = request.method;
    url = this.request.url;
    headers = this.request.headers ?? {};
  }
}

class Get extends CoffeeRequester {
  Get(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeRequester> subPath,
      dynamic decoder(dynamic)})
      : super(url,
            method: GetMethod,
            headers: headers,
            middlewares: middlewares,
            subPath: subPath,
            decoder: decoder);
}

class Post extends CoffeeRequester {
  Post(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeRequester> subPath,
      dynamic decoder(dynamic),
      dynamic encoder(dynamic)})
      : super(url,
            method: PostMethod,
            headers: headers,
            middlewares: middlewares,
            subPath: subPath,
            decoder: decoder,
            encoder: encoder);
}

class Put extends CoffeeRequester {
  Put(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeRequester> subPath,
      dynamic decoder(dynamic),
      dynamic encoder(dynamic)})
      : super(url,
            method: PostMethod,
            headers: headers,
            middlewares: middlewares,
            subPath: subPath,
            decoder: decoder,
            encoder: encoder);
}

class Delete extends CoffeeRequester {
  Delete(String url,
      {Map<String, String> headers,
      List<CoffeeMiddleware> middlewares,
      Map<String, CoffeeRequester> subPath,
      dynamic decoder(dynamic)})
      : super(url,
            method: GetMethod,
            headers: headers,
            middlewares: middlewares,
            subPath: subPath,
            decoder: decoder);
}

class _Requester {
  http.Client client;

  Future<CoffeeResponse> get(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.get(request.url, headers: request.headers),
          request.request);
    }
    return new CoffeeResponse(
        await client.get(request.url, headers: request.headers),
        request.request);
  }

  Future<CoffeeResponse> post(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.post(request.url,
              headers: request.headers, body: request.body),
          request.request);
    }
    return new CoffeeResponse(
        await client.post(request.url,
            headers: request.headers, body: request.body),
        request.request);
  }

  Future<CoffeeResponse> put(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.put(request.url,
              headers: request.headers, body: request.body),
          request.request);
    }
    return new CoffeeResponse(
        await client.put(request.url,
            headers: request.headers, body: request.body),
        request.request);
  }

  Future<CoffeeResponse> patch(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.patch(request.url,
              headers: request.headers, body: request.body),
          request.request);
    }
    return new CoffeeResponse(
        await client.patch(request.url,
            headers: request.headers, body: request.body),
        request.request);
  }

  Future<CoffeeResponse> delete(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.delete(request.url, headers: request.headers),
          request.request);
    }
    return new CoffeeResponse(
        await client.delete(request.url, headers: request.headers),
        request.request);
  }

  Future<CoffeeResponse> head(CoffeeRequest request) async {
    if (client == null) {
      return new CoffeeResponse(
          await http.head(request.url, headers: request.headers),
          request.request);
    }
    return new CoffeeResponse(
        await client.head(request.url, headers: request.headers),
        request.request);
  }
}

setCoffeeHttpClient(http.Client client) {
  _requester?.client = client;
}

_Requester _requester = new _Requester();
