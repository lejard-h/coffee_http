import "dart:async";

import "package:http/http.dart" as http;

import "coffee.dart";
import "request.dart";
import "response.dart";
import "middleware.dart";

void replaceParameters(CoffeeRequest request, Map<String, dynamic> parameters) {
  parameters?.forEach((String key, dynamic value) {
    request.url = request.url.replaceAll("{$key}", Uri.encodeComponent(value.toString()));
  });
}

void addQueryParameters(CoffeeRequest request, Map<String, dynamic> parameters) {
  if (parameters != null && parameters.isNotEmpty) {
    request.url = "${request.url}?";
    parameters?.forEach((String key, dynamic value) {
      request.url = "${request.url}${Uri.encodeQueryComponent(key)}=${Uri
          .encodeQueryComponent(value.toString())}&";
    });
  }
}

Future<CoffeeResponse> doRequest(CoffeeRequest request) async {
  _Requester _requester = new _Requester(request.config.client);
  CoffeeResponse response;
  String method = request.method.toLowerCase();

  try {
    if (method == GetMethod.toLowerCase()) {
      response = await _requester.get(request);
    } else if (method == PostMethod.toLowerCase()) {
      response = await _requester.post(request);
    } else if (method == PutMethod.toLowerCase()) {
      response = await _requester.put(request);
    } else if (method == PatchMethod.toLowerCase()) {
      response = await _requester.patch(request);
    } else if (method == DeleteMethod.toLowerCase()) {
      response = await _requester.delete(request);
    } else if (method == HeadMethod.toLowerCase()) {
      response = await _requester.head(request);
    }
  } on http.ClientException catch (exception) {
    response = new CoffeeResponse.Error(request.config, 404, exception.message);
  } catch (error) {
    response = new CoffeeResponse.Error(request.config, 404, error.toString());
  }
  return response;
}

List<CoffeeMiddleware> globalMiddlewares = [];

void applyPreMiddlewareWith(List<CoffeeMiddleware> listMiddleWare, CoffeeRequest request) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.pre(request);
  });
}

void applyPostMiddlewareWith(List<CoffeeMiddleware> listMiddleWare, CoffeeResponse response) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.post(response);
  });
}

void preMiddleware(CoffeeRequest request) {
  applyPreMiddlewareWith(globalMiddlewares, request);
  applyPreMiddlewareWith(request.config.requester.middlewares, request);
  applyPreMiddlewareWith(request.config.middlewares, request);
}

void postMiddleware(CoffeeResponse response) {
  applyPostMiddlewareWith(globalMiddlewares, response);
  applyPostMiddlewareWith(response.baseRequest.requester.middlewares, response);
  applyPostMiddlewareWith(response.baseRequest.middlewares, response);
}

class _Requester {
  http.Client client;

  _Requester(this.client);

  Future<CoffeeResponse> get(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.get(request.url, headers: request.headers);
    } else {
      res = await client.get(request.url, headers: request.headers);
    }
    return new CoffeeResponse(res, request.config);
  }

  Future<CoffeeResponse> post(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.post(request.url, headers: request.headers, body: request.body);
    } else {
      res = await client.post(request.url, headers: request.headers, body: request.body);
    }
    return new CoffeeResponse(res, request.config);
  }

  Future<CoffeeResponse> put(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.put(request.url, headers: request.headers, body: request.body);
    } else {
      res = await client.put(request.url, headers: request.headers, body: request.body);
    }
    return new CoffeeResponse(res, request.config);
  }

  Future<CoffeeResponse> patch(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.patch(request.url, headers: request.headers, body: request.body);
    } else {
      res = await client.patch(request.url, headers: request.headers, body: request.body);
    }
    return new CoffeeResponse(res, request.config);
  }

  Future<CoffeeResponse> delete(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.delete(request.url, headers: request.headers);
    } else {
      res = await client.delete(request.url, headers: request.headers);
    }
    return new CoffeeResponse(res, request.config);
  }

  Future<CoffeeResponse> head(CoffeeRequest request) async {
    http.Response res;

    if (client == null) {
      res = await http.head(request.url, headers: request.headers);
    } else {
      res = await client.head(request.url, headers: request.headers);
    }
    return new CoffeeResponse(res, request.config);
  }
}
