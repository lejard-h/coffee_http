/**
 * Created by lejard_h on 26/04/16.
 */

import "package:coffee_http/coffee.dart";
import "package:http/http.dart" as http;
import "../models/models.dart";

CoffeeRequester api;

void initApi([http.Client client]) {
  api = new CoffeeRequester(middlewares: [
    new ResolveApiMiddleware("http://localhost", 9000, subPath: "/cloud/v1"),
    JSON_CONTENT_TYPE,
    ENCODE_TO_JSON_MIDDLEWARE,
    DECODE_FROM_JSON_MIDDLEWARE,
  ], client: client);

  api["resources"] = new Get("/resources", decoder: ResourceModel.listDecoder);
  api["resources"]["read"] = new Get("/{name}", decoder: ResourceModel.decoder, middlewares: [LOGGER_MIDDLEWARE]);
  api["resources"]["create"] = new Post("/create", encoder: ResourceModel.encoder, decoder: ResourceModel.decoder);
}
