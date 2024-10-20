import 'package:flutter/material.dart';

/*when we need to parse API data. this class will helpfull it will give you easy
 access of data without using Map and if you see <T> in this class it will be any type,
its like dynamic, instead of creating new model for data output we use T, or any english Capital
alphabets you can use any like <B>*/
class DataOutput<T> {
  final int total;
  final List<T> modelList;
  final List? modelList2;
  final ExtraData? extraData;
  DataOutput({required this.total, required this.modelList, this.modelList2, this.extraData});

  DataOutput<T> copyWith({
    int? total,
    int? offset,
    List<T>? modelList,
    List<T>? modelList2,
    ExtraData? extraData,
  }) {
    return DataOutput<T>(
      total: total ?? this.total,
      modelList: modelList ?? this.modelList,
      modelList2: modelList2 ?? this.modelList2,
      extraData: extraData ?? this.extraData,
    );
  }
}

@protected
class ExtraData<T> {
  final T data;
  ExtraData({
    required this.data,
  });
}
