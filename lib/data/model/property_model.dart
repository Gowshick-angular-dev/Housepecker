// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_import
// To parse this JSON data, do
//
//     final propertyModel = propertyModelFromMap(jsonString);
import 'dart:convert';
import 'dart:developer';

import 'package:Housepecker/utils/Extensions/lib/adaptive_type.dart';

import '../../utils/helper_utils.dart';

class PropertyModel {
  PropertyModel(
      {this.id,
      this.title,
      this.type,
      this.customerName,
      this.brokerage,
      this.customerEmail,
      this.customerNumber,
      this.customerProfile,
      this.customerRole,
      this.rera,
      this.price,
        this.code,
      this.category,
      this.builtUpArea,
      this.plotArea,
      this.hectaArea,
      this.acre,
      this.houseType,
      this.furnished,
      this.unitType,
      this.description,
      this.address,
      this.clientAddress,
      this.properyType,
      this.titleImage,
      this.postCreated,
      this.sqft,
      this.gallery,
      this.totalView,
      this.status,
      this.state,
      this.city,
      this.highlight,
      this.country,
      this.addedBy,
      this.inquiry,
      this.promoted,
      this.isFavourite,
      this.rentduration,
      this.isInterested,
      this.isPremium,
      this.isDeal,
      this.favouriteUsers,
      this.interestedUsers,
      this.totalInterestedUsers,
      this.totalFavouriteUsers,
      this.parameters,
      this.latitude,
      this.longitude,
      this.threeDImage,
      this.advertisment,
      this.video,
      this.assignedOutdoorFacility,
      this.slugId,
      this.amenity,
      this.metaTitle,
      this.metaDescription,
      this.metaKeywords,
      this.metaImage,
      this.viewContact,
      this.titleimagehash});

  final int? id;
  final String? title;
  final String? type;
  final String? price;
  final String? code;
  final String? customerName;
  final String? rera;
  final String? brokerage;
  final String? customerEmail;
  final String? customerProfile;
  final int? customerRole;
  final String? customerNumber;
  final String? rentduration;
  final Categorys? category;
  final dynamic builtUpArea;
  final dynamic plotArea;
  final dynamic hectaArea;
  final dynamic acre;
  final dynamic houseType;
  final dynamic furnished;
  final UnitType? unitType;
  final String? description;
  final String? address;
  final String? clientAddress;
  String? properyType;
  final String? titleImage;
  final String? titleimagehash;
  final String? postCreated;
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;
  final String? metaImage;
  final int? sqft;
  final List<Gallery>? gallery;
  final int? totalView;
  final int? status;
  final String? state;
  final String? city;
  final String? highlight;
  final String? country;
  final int? addedBy;
  final bool? inquiry;
  final bool? promoted;
  final int? isFavourite;
  final int? viewContact;
  final int? isInterested;
  final int? isPremium;
  final int? isDeal;
  final List<dynamic>? favouriteUsers;
  final List<dynamic>? interestedUsers;
  final int? totalInterestedUsers;
  final int? totalFavouriteUsers;
  final List<Parameter>? parameters;
  final List<dynamic>? amenity;
  final List<AssignedOutdoorFacility>? assignedOutdoorFacility;
  final String? latitude;
  final String? longitude;
  final String? threeDImage;
  final String? video;
  final dynamic advertisment;
  final String? slugId;

  PropertyModel copyWith(
          {int? id,
          String? title,
          String? type,
          String? price,
          String? code,
          Categorys? category,
          dynamic builtUpArea,
          dynamic plotArea,
          dynamic hectaArea,
          dynamic acre,
          dynamic houseType,
          dynamic furnished,
          UnitType? unitType,
          String? description,
          String? address,
          String? clientAddress,
          String? properyType,
          String? titleImage,
          String? postCreated,
          int? sqft,
          List<Gallery>? gallery,
          int? totalView,
          int? status,
          String? state,
          String? city,
          String? highlight,
          String? country,
          int? addedBy,
          bool? inquiry,
          bool? promoted,
          int? isFavourite,
          int? viewContact,
          int? isInterested,
          int? isPremium,
          int? isDeal,
          List<dynamic>? favouriteUsers,
          List<dynamic>? interestedUsers,
          int? totalInterestedUsers,
          int? totalFavouriteUsers,
          List<Parameter>? parameters,
          List<dynamic>? amenity,
          List<AssignedOutdoorFacility>? assignedOutdoorFacility,
          String? latitude,
          String? longitude,
          String? threeDimage,
          String? video,
          dynamic advertisment,
          String? rentduration,
          String? titleImageHash}) =>
      PropertyModel(
          id: id ?? this.id,
          rentduration: rentduration ?? this.rentduration,
          advertisment: advertisment ?? this.advertisment,
          latitude: latitude ?? this.latitude,
          longitude: longitude ?? this.longitude,
          title: title ?? this.title,
          type: title ?? this.type,
          price: price ?? this.price,
          code: code ?? this.code,
          category: category ?? this.category,
          builtUpArea: builtUpArea ?? this.builtUpArea,
          plotArea: plotArea ?? this.plotArea,
          hectaArea: hectaArea ?? this.hectaArea,
          acre: acre ?? this.acre,
          houseType: houseType ?? this.houseType,
          furnished: furnished ?? this.furnished,
          unitType: unitType ?? this.unitType,
          description: description ?? this.description,
          address: address ?? this.address,
          clientAddress: clientAddress ?? this.clientAddress,
          properyType: properyType ?? this.properyType,
          titleImage: titleImage ?? this.titleImage,
          postCreated: postCreated ?? this.postCreated,
          sqft: sqft ?? this.sqft,
          gallery: gallery ?? this.gallery,
          totalView: totalView ?? this.totalView,
          status: status ?? this.status,
          state: state ?? this.state,
          city: city ?? this.city,
          highlight: highlight ?? this.highlight,
          country: country ?? this.country,
          addedBy: addedBy ?? this.addedBy,
          inquiry: inquiry ?? this.inquiry,
          promoted: promoted ?? this.promoted,
          isFavourite: isFavourite ?? this.isFavourite,
          viewContact: viewContact ?? this.viewContact,
          isInterested: isInterested ?? this.isInterested,
          isPremium: isPremium ?? this.isPremium,
          isDeal: isDeal ?? this.isDeal,
          favouriteUsers: favouriteUsers ?? this.favouriteUsers,
          interestedUsers: interestedUsers ?? this.interestedUsers,
          totalInterestedUsers:
              totalInterestedUsers ?? this.totalInterestedUsers,
          totalFavouriteUsers: totalFavouriteUsers ?? this.totalFavouriteUsers,
          parameters: parameters ?? this.parameters,
          amenity: amenity ?? this.amenity,
          threeDImage: threeDimage ?? threeDImage,
          video: video ?? this.video,
          assignedOutdoorFacility:
              assignedOutdoorFacility ?? this.assignedOutdoorFacility,
          titleimagehash: titleImageHash ?? titleimagehash);

  factory PropertyModel.fromMap(Map<String, dynamic> rawjson) {
    try {
      List list =
          (rawjson['parameters'] as List).map((e) => e['image']).toList();
      HelperUtils.precacheSVG(List.from(list));
    } catch (e) {}

    return PropertyModel(
        id: rawjson["id"],
        slugId: rawjson['slug_id'],
        rentduration: rawjson['rentduration'],
        customerEmail: rawjson['email'],
        customerProfile: rawjson['profile'],
        customerRole: rawjson['role'],
        customerNumber: rawjson['mobile'],
        customerName: rawjson['customer_name'],
        rera: rawjson['rera'],
        brokerage: rawjson['brokerage'],
        video: rawjson['video_link'],
        threeDImage: rawjson['threeD_image'],
        latitude: rawjson['latitude'].toString(),
        longitude: rawjson["longitude"].toString(),
        title: rawjson["title"].toString(),
        type: rawjson["is_type"].toString(),
        price: rawjson["price"].toString(),
        code: rawjson["code"].toString(),
        category: rawjson["category"] == null
            ? null
            : Categorys.fromMap(rawjson["category"]),
        builtUpArea: rawjson["built_up_area"],
        plotArea: rawjson["plot_area"],
        hectaArea: rawjson["hecta_area"],
        acre: rawjson["acre"],
        houseType: rawjson["house_type"],
        furnished: rawjson["furnished"],
        advertisment: rawjson['advertisement'],
        unitType: rawjson["unit_type"] == null
            ? null
            : UnitType.fromMap(rawjson["unit_type"]),
        description: rawjson["description"],
        address: rawjson["address"],
        clientAddress: rawjson["client_address"],
        properyType: rawjson["property_type"].toString(),
        titleImage: rawjson["title_image"],
        postCreated: rawjson["post_created"],
        sqft: rawjson["sqft"],
        gallery: List<Gallery>.from((rawjson["gallery"] as List)
            .map((x) => Gallery.fromMap(x is String ? json.decode(x) : x))),
        totalView: Adapter.forceInt((rawjson["total_view"] as dynamic)),
        status: Adapter.forceInt(rawjson["status"]),
        state: rawjson["state"],
        city: rawjson["city"],
        metaTitle: rawjson["meta_title"],
        metaDescription: rawjson["meta_description"],
        metaKeywords: rawjson["meta_keywords"],
        metaImage: rawjson["meta_image"],
        highlight: rawjson["highlight"],
        country: rawjson["country"],
        addedBy: Adapter.forceInt((rawjson["added_by"] as dynamic)),
        inquiry: rawjson["inquiry"],
        promoted: rawjson["promoted"],
        isFavourite: Adapter.forceInt(rawjson["is_favourite"]),
        viewContact: Adapter.forceInt(rawjson["view_contact"]),
        isInterested: Adapter.forceInt(rawjson["is_interested"]),
        isPremium: Adapter.forceInt(rawjson["is_premium"]),
        isDeal: Adapter.forceInt(rawjson["is_deal"]),
        favouriteUsers: rawjson["favourite_users"] == null
            ? null
            : List<dynamic>.from(rawjson["favourite_users"].map((x) => x)),
        amenity: rawjson["amenity"] == null
            ? null
            : List<dynamic>.from(rawjson["amenity"].map((x) => x)),
        interestedUsers: rawjson["interested_users"] == null
            ? null
            : List<dynamic>.from(rawjson["interested_users"].map((x) => x)),
        totalInterestedUsers:
            Adapter.forceInt(rawjson["total_interested_users"]),
        totalFavouriteUsers: Adapter.forceInt(rawjson["total_favourite_users"]),
        parameters: rawjson["parameters"] == null
            ? []
            : List<Parameter>.from((rawjson["parameters"] as List).map((x) {
                return Parameter.fromMap(x);
              })),
        assignedOutdoorFacility: rawjson["assign_facilities"] == null
            ? []
            : List<AssignedOutdoorFacility>.from(
                (rawjson["assign_facilities"] as List).map((x) {
                return AssignedOutdoorFacility.fromJson(x);
              })),
        titleimagehash: rawjson['title_image_hash']);
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "rentduration": rentduration,
        "mobile": customerNumber,
        "email": customerEmail,
        "customer_name": customerName,
        "rera": rera,
        "brokerage": brokerage,
        "profile": customerProfile,
        "role": customerRole,
        "threeD_image": threeDImage,
        "title": title,
        "type": type,
        "latitude": latitude,
        "longitude": longitude,
        "advertisment": advertisment,
        'video_link': video,
        "price": price,
        "code": code,
        "category": category?.toMap() ?? {},
        "built_up_area": builtUpArea,
        "plot_area": plotArea,
        "hecta_area": hectaArea,
        "acre": acre,
        "house_type": houseType,
        "furnished": furnished,
        "unit_type": unitType?.toMap() ?? {},
        "description": description,
        "address": address,
        "client_address": clientAddress,
        "property_type": properyType,
        "title_image": titleImage,
        "post_created": postCreated,
        "sqft": sqft,
        "gallery": List<Gallery>.from(gallery?.map((x) => x) ?? []),
        "total_view": totalView,
        "status": status,
        "state": state,
        "city": city,
        "meta_title": metaTitle,
        "meta_description": metaDescription,
        "meta_keywords": metaKeywords,
        "meta_image": metaImage,
        "highlight": highlight,
        "country": country,
        "added_by": addedBy,
        "inquiry": inquiry,
        "promoted": promoted,
        "is_favourite": isFavourite,
        "view_contact": viewContact,
        "is_interested": isInterested,
        "is_premium": isPremium,
        "is_deal": isDeal,
        "favourite_users": favouriteUsers == null
            ? null
            : List<dynamic>.from(favouriteUsers?.map((x) => x) ?? []),
        "amenity": amenity == null
            ? null
            : List<dynamic>.from(amenity?.map((x) => x) ?? []),
        "interested_users": interestedUsers == null
            ? null
            : List<dynamic>.from(interestedUsers?.map((x) => x) ?? []),
        "total_interested_users": totalInterestedUsers,
        "total_favourite_users": totalFavouriteUsers,
        "assign_facilities": assignedOutdoorFacility == null
            ? null
            : List<dynamic>.from(
                assignedOutdoorFacility?.map((e) => e.toJson()) ?? []),
        "parameters": parameters == null
            ? null
            : List<dynamic>.from(parameters?.map((x) => x.toMap()) ?? []),
        "title_image_hash": titleimagehash
      };

  @override
  String toString() {
    return 'PropertyModel(id: $id,rentduration:$rentduration , title: $title, type: $type,assigned_facilities:[$assignedOutdoorFacility]  advertisment:$advertisment, price: $price, category: $category,, builtUpArea: $builtUpArea, plotArea: $plotArea, hectaArea: $hectaArea, acre: $acre, houseType: $houseType, furnished: $furnished, unitType: $unitType, description: $description, address: $address, clientAddress: $clientAddress, properyType: $properyType, titleImage: $titleImage, title_image_hash: $titleimagehash, postCreated: $postCreated, gallery: $gallery, totalView: $totalView, status: $status, state: $state, city: $city, country: $country, addedBy: $addedBy, inquiry: $inquiry, promoted: $promoted, isFavourite: $isFavourite, isInterested: $isInterested, favouriteUsers: $favouriteUsers, interestedUsers: $interestedUsers, totalInterestedUsers: $totalInterestedUsers, totalFavouriteUsers: $totalFavouriteUsers, parameters: $parameters, latitude: $latitude, longitude: $longitude, threeD_image: $threeDImage, video: $video, amenity: $amenity)';
  }
}

class Categorys {
  Categorys({
    this.id,
    this.category,
    this.image,
  });

  final int? id;
  final String? category;
  final String? image;

  Categorys copyWith({
    int? id,
    String? category,
    String? image,
  }) =>
      Categorys(
        id: id ?? this.id,
        category: category ?? this.category,
        image: image ?? this.image,
      );

  factory Categorys.fromJson(String str) => Categorys.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Categorys.fromMap(Map<String, dynamic> json) => Categorys(
        id: json["id"],
        category: json["category"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "category": category,
        "image": image,
      };
}

class Parameter {
  Parameter({
    this.id,
    this.name,
    this.typeOfParameter,
    this.typeValues,
    this.image,
    this.value,
  });

  final int? id;
  final String? name;
  final String? typeOfParameter;
  final dynamic typeValues;
  final String? image;
  final dynamic value;

  Parameter copyWith({
    int? id,
    String? name,
    String? typeOfParameter,
    dynamic typeValues,
    String? image,
    dynamic value,
  }) =>
      Parameter(
        id: id ?? this.id,
        name: name ?? this.name,
        typeOfParameter: typeOfParameter ?? this.typeOfParameter,
        typeValues: typeValues ?? this.typeValues,
        image: image ?? this.image,
        value: value ?? this.value,
      );

  static dynamic ifListConvertToString(dynamic value) {
    if (value is List) {
      return value.join(",");
    }

    return value;
  }

  factory Parameter.fromMap(Map<String, dynamic> json) {
    return Parameter(
      id: json["id"],
      name: json["name"],
      typeOfParameter: json["type_of_parameter"],
      typeValues: json["type_values"],
      image: json["image"],
      value: ifListConvertToString(json['value']),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "type_of_parameter": typeOfParameter,
        "type_values": typeValues,
        "image": image,
        "value": value,
      };

  @override
  String toString() {
    return 'Parameter(id: $id, name: $name, typeOfParameter: $typeOfParameter, typeValues: $typeValues, image: $image, value: $value)';
  }
}

class Amenity {
  Amenity({
    this.id,
    this.name,
    this.image,
  });

  final int? id;
  final String? name;
  final String? image;

  Amenity copyWith({
    int? id,
    String? name,
    String? image,
  }) =>
      Amenity(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  static dynamic ifListConvertToString(dynamic value) {
    if (value is List) {
      return value.join(",");
    }

    return value;
  }

  factory Amenity.fromMap(Map<String, dynamic> json) {
    return Amenity(
      id: json["id"],
      name: json["name"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "image": image,
  };

  @override
  String toString() {
    return 'Parameter(id: $id, name: $name, image: $image)';
  }
}

class UnitType {
  UnitType({
    this.id,
    this.measurement,
  });

  final int? id;
  final String? measurement;

  UnitType copyWith({
    int? id,
    String? measurement,
  }) =>
      UnitType(
        id: id ?? this.id,
        measurement: measurement ?? this.measurement,
      );

  factory UnitType.fromJson(String str) => UnitType.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UnitType.fromMap(Map<String, dynamic> json) => UnitType(
        id: json["id"],
        measurement: json["measurement"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "measurement": measurement,
      };
}

class Gallery {
  final int id;
  final String image;
  final String imageUrl;
  final bool? isVideo;
  Gallery(
      {required this.id,
      required this.image,
      required this.imageUrl,
      this.isVideo});

  Gallery copyWith({
    int? id,
    String? image,
    String? imageUrl,
  }) {
    return Gallery(
      id: id ?? this.id,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'image_url': imageUrl,
    };
  }

  factory Gallery.fromMap(Map<String, dynamic> map) {
    return Gallery(
      id: map['id'] as int,
      image: map['image'] as String,
      imageUrl: map['image_url'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory Gallery.fromJson(String source) =>
      Gallery.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Gallery(id: $id, image: $image, imageUrl: $imageUrl)';

  @override
  bool operator ==(covariant Gallery other) {
    if (identical(this, other)) return true;

    return other.id == id && other.image == image && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ image.hashCode ^ imageUrl.hashCode;
}

class AssignedOutdoorFacility {
  int? id;
  int? propertyId;
  int? facilityId;
  int? distance;
  String? image;
  String? name;
  String? createdAt;
  String? updatedAt;

  AssignedOutdoorFacility(
      {this.id,
      this.propertyId,
      this.facilityId,
      this.distance,
      this.createdAt,
      this.name,
      this.image,
      this.updatedAt});

  AssignedOutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    propertyId = json['property_id'];
    facilityId = json['facility_id'];
    distance = json['distance'];
    createdAt = json['created_at'];
    image = json['image'];
    name = json['name'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['property_id'] = this.propertyId;
    data['facility_id'] = this.facilityId;
    data['distance'] = this.distance;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['image'] = image;
    data['name'] = name;
    return data;
  }

  @override
  String toString() {
    return 'AssignedOutdoorFacility{id: $id, propertyId: $propertyId, facilityId: $facilityId, distance: $distance, image: $image, name: $name, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
