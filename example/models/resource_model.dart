/**
 * Created by lejard_h on 25/04/16.
 */

import "../convert/convert.dart";

class ResourceModel {
  String name;
  num capacity;

  ResourceModel();

  factory ResourceModel.fromMap(Map json) =>
      new ResourceModelDecoder().convert(json);

  Map toMap() => new ResourceModelEncoder().convert(this);

  String toString() => toMap().toString();

  static ResourceModel decoder(Map json) => new ResourceModel.fromMap(json);

  static List<ResourceModel> listDecoder(List json) {
    List<ResourceModel> list = [];
    json.forEach((Map data) => list.add(decoder(data)));
    return list;
  }

  static Map encoder(ResourceModel data) => data.toMap();
}