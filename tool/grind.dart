/**
 * Created by lejard_h on 25/04/16.
 */

import "package:grinder/grinder.dart";
import "package:dogma_codegen/build.dart" as dogma_build;

main(List<String> args) {
  grind(args);
}

@Task()
void buildDogmaExample() {
  dogma_build.build([],
      modelLibrary: "example/models/models.dart",
      modelPath: "example/models",
      convertPath: "example/convert",
      convertLibrary: "example/convert/convert.dart",
      mapper: false,
      unmodifiable: false);
}
