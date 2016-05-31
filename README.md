# coffee_http

Easy http request for browser and server.

## Usage

### A simple usage example:

```dart
import "package:coffee_http/coffee.dart";

main() {

    Get request = new Get("http://localhost/data", middlewares: [
        JSON_CONTENT_TYPE,
        ENCODE_TO_JSON_MIDDLEWARE,
        DECODE_FROM_JSON_MIDDLEWARE,
    ]);
    
    request.execute().then((CoffeeResponse res) => print(res.decodedBody));

}
```

### More complexe example:

[Example](https://github.com/lejard-h/coffee_http/tree/master/example)

#### Model

```dart
class ResourceModel {
  String name;

  ResourceModel(this.name);

  ResourceModel.fromMap(Map json) {
    name = json["name"];
  }

  Map toMap() => { "name": name };

  String toString() => toMap().toString();

}
```

#### Define Requests

```dart
CoffeeRequester api = new CoffeeRequester(middlewares: [
        new ResolveApiMiddleware("http://localhost", 9000, subPath: "/api"),
        LOGGER_MIDDLEWARE,
        JSON_CONTENT_TYPE,
        ENCODE_TO_JSON_MIDDLEWARE,
        DECODE_FROM_JSON_MIDDLEWARE,
    ], client: client);

api["resources"] = new Get("/resources", decoder: ResourceModel.listDecoder);
api["resources"]["read"] = new Get("/{name}", decoder: ResourceModel.decoder);
api["resources"]["create"] = new Post("/create",
    encoder: ResourceModel.encoder, decoder: ResourceModel.decoder);
```

#### Use it

```dart
initApi();

api["resources"].execute().then((CoffeeResponse _res) {
print(_res.decodedBody as List<ResourceModel>);
});

api["resources"]["create"]
  .execute(body: new ResourceModel()
    ..name = "toto"
    ..capacity = 3)
  .then((CoffeeResponse _res) {
if (_res.statusCode == 200) {
  ResourceModel resource = _res.decodedBody as ResourceModel;
  print(resource);
}
});

api["resources"]["read"]
  .execute(parameters: {"name": "toto"}).then((CoffeeResponse _res) {
if (_res.statusCode == 200) {
  ResourceModel resource = _res.decodedBody as ResourceModel;
  print(resource);
}
});
```