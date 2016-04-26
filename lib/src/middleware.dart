/**
 * Created by lejard_h on 25/04/16.
 */

part of coffee;

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

List<CoffeeMiddleware> _globalMiddlewares = [];

_applyPreMiddlewareWith(
    List<CoffeeMiddleware> listMiddleWare, CoffeeRequest request) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.pre(request);
  });
}

_applyPostMiddlewareWith(
    List<CoffeeMiddleware> listMiddleWare, CoffeeResponse response) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.post(response);
  });
}

_preMiddleware(CoffeeRequest request) {
  _applyPreMiddlewareWith(_globalMiddlewares, request);
  _applyPreMiddlewareWith(request.config.requester.middlewares, request);
  _applyPreMiddlewareWith(request.config.middlewares, request);
}

_postMiddleware(CoffeeResponse response) {
  _applyPostMiddlewareWith(_globalMiddlewares, response);
  _applyPostMiddlewareWith(
      response.baseRequest.requester.middlewares, response);
  _applyPostMiddlewareWith(response.baseRequest.middlewares, response);
}

class ResolveApiMiddleware extends CoffeeMiddleware {
  final String hostname;
  final num port;
  final String subPath;

  ResolveApiMiddleware(this.hostname, this.port, {this.subPath}) : super();

  CoffeeRequest pre(CoffeeRequest request) {
    request.url = "$hostname:$port${(subPath ?? "")}${request.url}";
    return request;
  }
}

class HeadersMiddleware extends CoffeeMiddleware {
  final Map<String, String> headers;

  HeadersMiddleware(this.headers);

  CoffeeRequest pre(CoffeeRequest request) {
    request.headers.addAll(headers);
    return request;
  }
}

class BodyEncoderMiddleware extends CoffeeMiddleware {
  Function _bodyEncoder;

  BodyEncoderMiddleware(bodyEncoder(body)) {
    this._bodyEncoder = bodyEncoder;
  }

  CoffeeRequest pre(CoffeeRequest request) {
    if (request.config != GetMethod) {
      request.body = _bodyEncoder(request.body);
    }
    return request;
  }
}

class BodyDecoderMiddleware extends CoffeeMiddleware {
  Function _bodyDecoder;

  BodyDecoderMiddleware(dynamic bodyDecoder(body)) {
    this._bodyDecoder = bodyDecoder;
  }

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

BodyEncoderMiddleware ENCODE_TO_JSON_MIDDLEWARE =
    new BodyEncoderMiddleware((body) => JSON.encode(body));
BodyDecoderMiddleware DECODE_FROM_JSON_MIDDLEWARE =
    new BodyDecoderMiddleware((body) => JSON.decode(body));

HeadersMiddleware JSON_CONTENT_TYPE =
    new HeadersMiddleware({"Content-Type": "application/json"});

LoggerMiddleware LOGGER_MIDDLEWARE = new LoggerMiddleware(
    logger: (CoffeeResponse res) => print(
        "${res.baseRequest.method.toUpperCase()} [${res.request.url}] [${res.statusCode}]"));

coffeeMiddlewares(List<CoffeeMiddleware> middlewares) {
  _globalMiddlewares = middlewares ?? [];
}
