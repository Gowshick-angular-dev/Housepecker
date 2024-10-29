// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PropertyFilterModel {
  final String propertyType;
  final String? SaleType;
  final String maxPrice;
  final String minPrice;
  final String categoryId;
  final String? amenities;
  final String? possessionStart;
  final String? projectType;
  final String? post_by;
  final String? max_size;
  final String? min_size;
  final String? parametersId;
  final String? parametersVal;
  final String postedSince;
  final String city;
  final String state;
  final String country;
  final String? area;
  final String? allProperties;
  final String? allProjects;
  final String? premium;
  final String? deal;
  final String? brokerage;
  PropertyFilterModel(
      {required this.propertyType,
      required this.maxPrice,
      required this.minPrice,
      required this.categoryId,
      this.amenities,
      this.possessionStart,
      this.projectType,
      this.post_by,
      this.max_size,
      this.min_size,
      this.SaleType,
      this.parametersId,
      this.parametersVal,
      this.area,
      this.allProperties,
      this.allProjects,
      this.brokerage,
      this.premium,
      this.deal,
      required this.postedSince,
      required this.city,
      required this.state,
      required this.country
      });

  PropertyFilterModel copyWith(
      {String? propertyType,
      String? maxPrice,
      String? minPrice,
      String? categoryId,
      String? amenities,
      String? possessionStart,
      String? projectType,
      String? post_by,
      String? max_size,
      String? min_size,
      String? parametersId,
      String? parametersVal,
      String? postedSince,
      String? city,
      String? state,
      String? country,
      String? area,
      String? premium,
      String? deal,
      String? allProperties,
      String? allProjects,
      String? brokerage,
      }) {
    return PropertyFilterModel(
        propertyType: propertyType ?? this.propertyType,
        maxPrice: maxPrice ?? this.maxPrice,
        minPrice: minPrice ?? this.minPrice,
        categoryId: categoryId ?? this.categoryId,
        amenities: amenities ?? this.amenities,
        possessionStart: possessionStart ?? this.possessionStart,
        projectType: projectType ?? this.projectType,
        post_by: post_by ?? this.post_by,
        max_size: max_size ?? this.max_size,
        min_size: min_size ?? this.min_size,
        parametersId: parametersId ?? this.parametersId,
        parametersVal: parametersVal ?? this.parametersVal,
        postedSince: postedSince ?? this.postedSince,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        area: area ?? this.area,
        premium: premium ?? this.premium,
        deal: deal ?? this.deal,
        allProperties: allProperties ?? this.allProperties,
        allProjects: allProjects ?? this.allProjects,
        brokerage: brokerage ?? this.brokerage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'property_type': propertyType,
      'max_price': maxPrice,
      'min_price': minPrice,
      'category_id': categoryId,
      'amenities': amenities,
      'possession_start': possessionStart,
      'proj_type': projectType,
      'post_by': post_by,
      'max_size': max_size,
      'min_size': min_size,
      'param_id': parametersId,
      'param_value': parametersVal,
      'posted_since': postedSince,
      "area": area,
      "city": city,
      "state": state,
      "country": country,
      "premium": premium,
      "deal_of_month": deal,
      "all_properties": allProperties,
      "all_project": allProjects,
      "brokerage": brokerage,
    };
  }

  @override
  String toString() {
    return 'PropertyFilterModel(propertyType: $propertyType, maxPrice: $maxPrice, minPrice: $minPrice, categoryId: $categoryId, postedSince: $postedSince)';
  }

  factory PropertyFilterModel.createEmpty() {
    return PropertyFilterModel(
        propertyType: "",
        maxPrice: "",
        minPrice: "",
        categoryId: "",
        amenities: "",
        post_by: "",
        max_size: "",
        min_size: "",
        parametersId: '',
        parametersVal: '',
        postedSince: "",
        city: '',
        country: '',
        state: '',
        area: '',
        allProperties: '',
        allProjects: '',
        brokerage: '',
        premium: '',
        deal: '',
    );
  }
  factory PropertyFilterModel.fromMap(Map<String, dynamic> map) {
    return PropertyFilterModel(
      city: map['city'].toString(),
      state: map['state'].toString(),
      country: map['country'].toString(),
      propertyType: map['property_type'].toString(),
      maxPrice: map['max_price'].toString(),
      minPrice: map['min_price'].toString(),
      categoryId: map['category_id'].toString(),
      postedSince: map['posted_since'].toString(),
      amenities: map['amenities'].toString(),
      post_by: map['post_by'].toString(),
      max_size: map['max_size'].toString(),
      min_size: map['min_size'].toString(),
      parametersId: map['param_id'].toString(),
      parametersVal: map['param_value'].toString(),
      area: map['area'].toString(),
      allProperties: map['all_properties'].toString(),
      allProjects: map['all_projects'].toString(),
      brokerage: map['brokerage'].toString(),
      premium: map['premium'].toString(),
      deal: map['deal_of_month'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PropertyFilterModel.fromJson(String source) =>
      PropertyFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant PropertyFilterModel other) {
    if (identical(this, other)) return true;

    return other.propertyType == propertyType &&
        other.maxPrice == maxPrice &&
        other.minPrice == minPrice &&
        other.categoryId == categoryId &&
        other.postedSince == postedSince;
  }

  @override
  int get hashCode {
    return propertyType.hashCode ^
        maxPrice.hashCode ^
        minPrice.hashCode ^
        categoryId.hashCode ^
        postedSince.hashCode;
  }
}
