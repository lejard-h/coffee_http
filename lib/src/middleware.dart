/**
 * Created by lejard_h on 25/04/16.
 */

part of coffee;

abstract class CoffeeMiddleware {
  CoffeeRequest request(CoffeeRequest request) {
    return request;
  }

  CoffeeResponse response(CoffeeResponse response) {
    return response;
  }
}

List<CoffeeMiddleware> _middlewares = [];

_applyPreMiddlewareWith(
    List<CoffeeMiddleware> listMiddleWare, CoffeeRequest request) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.request(request);
  });
}

_applyPostMiddlewareWith(
    List<CoffeeMiddleware> listMiddleWare, CoffeeResponse response) {
  listMiddleWare?.forEach((CoffeeMiddleware middleware) {
    middleware.response(response);
  });
}

_preMiddleware(CoffeeRequest request) {
  _applyPreMiddlewareWith(_middlewares, request);
  _applyPreMiddlewareWith(request.request.middlewares, request);
}

_postMiddleware(CoffeeResponse response) {
  _applyPostMiddlewareWith(_middlewares, response);
  _applyPostMiddlewareWith(response.baseRequest.middlewares, response);
}

class ResolveApiMiddleware extends CoffeeMiddleware {
  final String hostname;
  final num port;
  final String subPath;

  ResolveApiMiddleware(this.hostname, this.port, {this.subPath});

  CoffeeRequest request(CoffeeRequest request) {
    request.url = "$hostname:$port${(subPath ?? "")}${request.url}";
    return request;
  }
}

class HeadersMiddleware extends CoffeeMiddleware {
  final Map<String, String> headers;

  HeadersMiddleware(this.headers);

  CoffeeRequest request(CoffeeRequest request) {
    request.headers.addAll(headers);
    return request;
  }
}

class BodyEncoderMiddleware extends CoffeeMiddleware {
  Function _bodyEncoder;

  BodyEncoderMiddleware(bodyEncoder(body)) {
    this._bodyEncoder = bodyEncoder;
  }

  CoffeeRequest request(CoffeeRequest request) {
    if (request.request != GetMethod) {
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

  CoffeeResponse response(CoffeeResponse response) {
    if (response.decodedBody == null) {
      response.decodedBody = response.body;
    }
    response.decodedBody = _bodyDecoder(response.decodedBody);
    return response;
  }
}

BodyEncoderMiddleware ENCODE_TO_JSON_MIDDLEWARE =
    new BodyEncoderMiddleware((body) => JSON.encode(body));
BodyDecoderMiddleware DECODE_FROM_JSON_MIDDLEWARE =
    new BodyDecoderMiddleware((body) => JSON.decode(body));

HeadersMiddleware JSON_CONTENT_TYPE =
    new HeadersMiddleware({"Content-Type": "application/json"});

coffeeMiddlewares(List<CoffeeMiddleware> middlewares) {
  _middlewares = middlewares ?? [];
}
