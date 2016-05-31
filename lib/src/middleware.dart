
import "dart:convert";

import "coffee.dart";
import "request.dart";
import "response.dart";
import "utils.dart";

class CoffeeMiddleware {
  Function response;
  Function request;

  CoffeeMiddleware(
      {CoffeeResponse response(CoffeeResponse res),
      CoffeeRequest request(CoffeeRequest req)}) {
    this.response = response;
    this.request = request;
  }

  CoffeeRequest pre(CoffeeRequest req) {
    if (request != null) {
      return request(req);
    }
    return req;
  }

  CoffeeResponse post(CoffeeResponse res) {
    if (response != null) {
      return response(res);
    }
    return res;
  }
}


class ResolveApiMiddleware extends CoffeeMiddleware {
  final String hostname;
  final num port;
  final String subPath;

  ResolveApiMiddleware(this.hostname, this.port, {this.subPath}) : super();

  @override
  CoffeeRequest pre(CoffeeRequest request) {
    request.url = "$hostname:$port${(subPath ?? "")}${request.url}";
    return request;
  }
}

class HeadersMiddleware extends CoffeeMiddleware {
  final Map<String, String> headers;

  HeadersMiddleware(this.headers);

  @override
  CoffeeRequest pre(CoffeeRequest request) {
    request.headers.addAll(headers);
    return request;
  }
}

class BodyEncoderMiddleware extends CoffeeMiddleware {
  Function _bodyEncoder;

  BodyEncoderMiddleware(bodyEncoder(dynamic body)) {
    this._bodyEncoder = bodyEncoder;
  }

  @override
  CoffeeRequest pre(CoffeeRequest request) {
    if (request.config != GetMethod) {
      request.body = _bodyEncoder(request.body);
    }
    return request;
  }
}

class BodyDecoderMiddleware extends CoffeeMiddleware {
  Function _bodyDecoder;

  BodyDecoderMiddleware(dynamic bodyDecoder(dynamic body)) {
    this._bodyDecoder = bodyDecoder;
  }

  @override
  CoffeeResponse post(CoffeeResponse response) {
    if (response.decodedBody == null) {
      response.decodedBody = response.body;
    }
    response.decodedBody = _bodyDecoder(response.decodedBody);
    return response;
  }
}

class LoggerMiddleware extends CoffeeMiddleware {
  LoggerMiddleware({logger(CoffeeResponse res)}) {
    response = (CoffeeResponse res) {
      logger(res);
      return res;
    };
  }
}

LoggerMiddleware LOGGER_MIDDLEWARE = new LoggerMiddleware(
    logger: (CoffeeResponse res) => print(
        "${res.baseRequest.method.toUpperCase()} [${res.request.url}] [${res.statusCode}]"));

void coffeeMiddlewares(List<CoffeeMiddleware> middlewares) {
  globalMiddlewares = middlewares ?? [];
}

class JsonMiddleware extends CoffeeMiddleware {
  @override
  CoffeeRequest pre(CoffeeRequest request) {
    if (request.headers == null) {
      request.headers = {};
    }
    if (request.body != null) {
      request.headers["content-type"] =
      "application/json${request.headers["content-type"] != null ? ",${request.headers["content-type"]}" : "" }";
      request.body = JSON.encode(request.body);
    }
    return request;
  }

  bool _isJSON(String json) {
    return json != null &&
        ((json.startsWith("{") && json.endsWith("}")) ||
            (json.startsWith("[") && json.endsWith("]")));
  }


  @override
  CoffeeResponse post(CoffeeResponse response) {
    if (response.decodedBody == null) {
      response.decodedBody = response.body;
    }

    if (response.headers.containsKey("content-type") &&
        response.headers["content-type"].contains("application/json") &&
        response.decodedBody is String &&
        _isJSON(response.decodedBody)) {
      response.decodedBody = JSON.decode(response.decodedBody);
    }
    return response;
  }
}

CoffeeMiddleware JSON_MIDDLEWARE = new JsonMiddleware();
