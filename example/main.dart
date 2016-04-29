/**
 * Created by lejard_h on 25/04/16.
 */

import "dart:async";
import "package:coffee_http/coffee.dart";
import "models/models.dart";
import "api/api.dart";

Future<Null> main() async {
  initApi();

  api["resources"].execute().then((CoffeeResponse _res) {
    print(_res.decodedBody as List<ResourceModel>);
  });

  api["resources"]["create"]
      .execute(body: new ResourceModel()
        ..name = "truc"
        ..capacity = 3)
      .then((CoffeeResponse _res) {
    if (_res.statusCode == 200) {
      ResourceModel resource = _res.decodedBody as ResourceModel;
      print(resource);
    }
  });

  api["resources"]["read"].execute(parameters: {"name": "truc"}).then((CoffeeResponse _res) {
    if (_res.statusCode == 200) {
      ResourceModel resource = _res.decodedBody as ResourceModel;
      print(resource);
    }
  });
}
