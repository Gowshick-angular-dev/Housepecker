import '../../utils/Extensions/lib/adaptive_type.dart';

class ArticleModel {
  int? id;
  String? image;
  String? title;
  String? slug;
  String? description;
  String? date;

  ArticleModel({this.id, this.image, this.title, this.slug, this.description, this.date});

  ArticleModel.fromJson(Map<String, dynamic> json) {
    id = Adapter.forceInt(json['id']);
    image = json['image'];
    title = json['title'];
    slug = json['slug_id'];
    description = json['description'];
    date = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['title'] = title;
    data['slug_id'] = slug;
    data['description'] = description;
    data['created_at'] = date;
    return data;
  }
}
