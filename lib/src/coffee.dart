part of coffee;

const GetMethod = "Get";
const PostMethod = "Post";
const PutMethod = "Put";
const DeleteMethod = "Delete";
const PatchMethod = "Patch";
const HeadMethod = "Head";

class CoffeeRequester {
  List<CoffeeMiddleware> middlewares;
  Map<String, CoffeeHttpRequest> requests;
  http.Client client;

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


  operator []=(String name, CoffeeHttpRequest request) {
    configureRequest(request);
    if (requests == null) {
      requests = {};
    }
    requests[name] = request;
  }

  configureRequest(CoffeeHttpRequest request) {
    request.client = this.client;
    request.requester = this;
  }
}

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

  CoffeeHttpRequest operator [](String name) {
    CoffeeHttpRequest request = requests.containsKey(name) ? requests[name] : null;

    if (request != null) {
      request.requester = this.requester;
    }
    return request;
  }

  operator []=(String name, CoffeeHttpRequest request) {
    request.url = url + request.url;
    super[name] = request;
  }

  Future<CoffeeResponse> execute({body, Map queryParameters, Map parameters}) {
    return coffee(this,
        body: body, queryParameters: queryParameters, parameters: parameters);
  }
}

_replaceParameters(CoffeeRequest request, Map<String, dynamic> parameters) {
  parameters?.forEach((String key, value) {
    request.url =
        request.url.replaceAll("{$key}", Uri.encodeComponent(value.toString()));
  });
}

_addQueryParameters(CoffeeRequest request, Map<String, dynamic> parameters) {
  if (parameters != null && parameters.isNotEmpty) {
    request.url = "${request.url}?";
    parameters?.forEach((String key, value) {
      request.url = "${request.url}${Uri.encodeQueryComponent(key)}=${Uri
          .encodeQueryComponent(value.toString())}&";
    });
  }
}

Future<CoffeeResponse> _doRequest(CoffeeRequest request) {
  _Requester _requester = new _Requester(request.config.client);

  if (request.method.toLowerCase() == GetMethod.toLowerCase()) {
    return _requester.get(request);
  } else if (request.method.toLowerCase() == PostMethod.toLowerCase()) {
    return _requester.post(request);
  } else if (request.method.toLowerCase() == PutMethod.toLowerCase()) {
    return _requester.put(request);
  } else if (request.method.toLowerCase() == PatchMethod.toLowerCase()) {
    return _requester.patch(request);
  } else if (request.method.toLowerCase() == DeleteMethod.toLowerCase()) {
    return _requester.delete(request);
  } else if (request.method.toLowerCase() == HeadMethod.toLowerCase()) {
    return _requester.head(request);
  }
  throw "Http method ${request.method} not found";
  return null;
}

Future<CoffeeResponse> coffee(CoffeeHttpRequest request,
    {body, Map queryParameters, Map parameters}) async {
  CoffeeRequest _request = new CoffeeRequest(request, body);

  if (request.encoder != null) {
    _request.body = request.encoder(_request.body);
  }

  _replaceParameters(_request, parameters);
  _addQueryParameters(_request, queryParameters);

  _preMiddleware(_request);

  CoffeeResponse res = await _doRequest(_request);

  _postMiddleware(res);
  if (request.decoder != null) {
    res.decodedBody = request.decoder(res.decodedBody);
  }

  return res;
}

http.Client sharedClient;
