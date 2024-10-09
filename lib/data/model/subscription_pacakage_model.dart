// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Housepecker/utils/Extensions/lib/adaptive_type.dart';

class SubscriptionPackageModel {
  int? id;
  String? name;
  String? label;
  int? duration;
  num? price;
  num? offerPrice;
  int? status;
  int? numberofUnits;
  dynamic propertyLimit;
  dynamic addonLimit;
  dynamic projectLimit;
  dynamic advertisementlimit;
  String? createdAt;
  String? updatedAt;

  SubscriptionPackageModel(
      {this.id,
      this.name,
      this.label,
      this.duration,
      this.price,
      this.numberofUnits,
      this.offerPrice,
      this.status,
      this.propertyLimit,
      this.projectLimit,
      this.advertisementlimit,
      this.addonLimit,
      this.createdAt,
      this.updatedAt});

  SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    propertyLimit = json['property_limit'];
    advertisementlimit = json['advertisement_limit'];
    projectLimit = json['project_limit'];
    addonLimit = json['addon_limit'];
    id = json['id'];
    numberofUnits = json['no_of_units'];
    name = json['name'];
    label = json['label'];
    duration = json['duration'];
    price = json['price'];
    offerPrice = json['offer_price'];
    status = Adapter.forceInt(json['status']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['label'] = label;
    data['duration'] = duration;
    data['price'] = price;
    data['no_of_units'] = numberofUnits;
    data['offer_price'] = offerPrice;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['property_limit'] = propertyLimit;
    data['addon_limit'] = addonLimit;
    data['project_limit'] = projectLimit;
    data['advertisement_limit'] = advertisementlimit;
    return data;
  }

  @override
  String toString() {
    return 'SubscriptionPackageModel(id: $id, name: $name, label: $label, duration: $duration, price: $price, numberofUnits: $numberofUnits, offerPrice: $offerPrice, status: $status, propertyLimit: $propertyLimit, advertisementlimit: $advertisementlimit, projectLimit: $projectLimit, addonLimit: $addonLimit, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
