/**
 * Created by lejard_h on 25/04/16.
 */

import "package:coffee_http/coffee.dart";
import "models/models.dart";

CoffeeRequester resources = new Get("/resources",
    subPath: {
      "read": new Get("/{name}", decoder: ResourceModel.decoder),
      "create": new Post("/create",
          encoder: ResourceModel.encoder, decoder: ResourceModel.decoder)
    },
    decoder: ResourceModel.listDecoder);

main() async {

  coffeeMiddlewares([
    new ResolveApiMiddleware("http://localhost", 9000, subPath: "/cloud/v1"),
    JSON_CONTENT_TYPE,
    ENCODE_TO_JSON_MIDDLEWARE,
    DECODE_FROM_JSON_MIDDLEWARE
  ]);

  CoffeeResponse res;

  res = await resources.execute();
  print(res.decodedBody as List<ResourceModel>);

  res = await resources["create"].execute(body: new ResourceModel()
    ..name = "truc"
    ..capacity = 3);
  if (res.statusCode == 200) {
    ResourceModel resource = res.decodedBody as ResourceModel;
    print(resource);
  } else {
    print(res.body);
  }

  res = await resources["read"].execute(parameters: {"name": "toto"});
  if (res.statusCode == 200) {
    ResourceModel resource = res.decodedBody as ResourceModel;
    print(resource);
  } else {
    print(res.body);
  }
}
