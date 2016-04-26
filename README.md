# coffee_http

Easy http request for browser and server.

## Usage

A simple usage example:

### Model

    class ResourceModel {
      String name;
    
      ResourceModel(this.name);
    
      ResourceModel.fromMap(Map json) {
        name = json["name"];
      }
    
      Map toMap() => { "name": name };
    
      String toString() => toMap().toString();
    
    }

### Define Requests
    Get resources = new Get("/resources",
            decoder: (List json) {
                   List<ResourceModel> list = [];
                   json.forEach((Map data) => list.add( new ResourceModel.fromMap(data)));
                   return list;
            },
            subPath: {
              "read": new Get("/{name}", decoder: (Map json) => new ResourceModel.fromMap(json)),
              "create": new Post("/create",
                  encoder: (ResourceModel model) => model.toMap(), decoder: (Map json) => new ResourceModel.fromMap(json))
            },
          );

### Use it

    import 'package:coffee_http/coffee.dart';
    import "package:http/browser_client.dart" as http; /// if you want to use in browser

    main() async {
         
        /// if you want to use it in browser
        setCoffeeHttpClient(new http.BrowserClient());
        
        coffeeMiddlewares([
              new ResolveApiMiddleware("http://localhost", 9000, subPath: "/api"),
              JSON_CONTENT_TYPE,
              ENCODE_TO_JSON_MIDDLEWARE,
              DECODE_FROM_JSON_MIDDLEWARE
          ]);
          
        CoffeeResponse res;
        
        res = await resources.execute();
        print(res.decodedBody as List<ResourceModel>);
          
        res = await resources["create"].execute(body: new ResourceModel("test"));
        print(resource as ResourceModel);
      
    }