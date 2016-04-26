/**
 * Created by lejard_h on 26/04/16.
 */

import 'package:http/browser_client.dart' as http;
import "package:coffee_http/coffee.dart";
import "models/models.dart";
import "api/api.dart";

void main() {
  initApi(new http.BrowserClient());

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

  api["resources"]["read"]
      .execute(parameters: {"name": "truc"}).then((CoffeeResponse _res) {
    if (_res.statusCode == 200) {
      ResourceModel resource = _res.decodedBody as ResourceModel;
      print(resource);
    }
  });
}
