class SequenceListResponseModel {
  final String tableName;
  final int nextId;

  SequenceListResponseModel({
    required this.tableName,
    required this.nextId,
  });

  factory SequenceListResponseModel.fromJson(Map<String, dynamic> json) {
    return SequenceListResponseModel(
      tableName: json['TABLE_NAME'] != null ? json['TABLE_NAME'] as String : "",
      nextId: json['NEXT_ID'] != null ? json['NEXT_ID'] as int : 0,
    );
  }
}

class SequenceListResultModel {
  List<SequenceListResponseModel> sequence;

  SequenceListResultModel({required this.sequence});

  factory SequenceListResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<SequenceListResponseModel> sequenceList =
        list.map((i) => SequenceListResponseModel.fromJson(i)).toList();
    return SequenceListResultModel(sequence: sequenceList);
  }
}

// 카테고리
class BasicCategorisResponseModel {
  final int cateId;
  final String category;

  BasicCategorisResponseModel({
    required this.cateId,
    required this.category,
  });

  factory BasicCategorisResponseModel.fromJson(Map<String, dynamic> json) {
    return BasicCategorisResponseModel(
      cateId: json['cate_id'] != null ? json['cate_id'] as int : 0,
      category: json['category'] != null ? json['category'] as String : "",
    );
  }
}

class BasicCategorisResultModel {
  List<BasicCategorisResponseModel> category;

  BasicCategorisResultModel({required this.category});

  factory BasicCategorisResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<BasicCategorisResponseModel> categoryList =
        list.map((i) => BasicCategorisResponseModel.fromJson(i)).toList();
    return BasicCategorisResultModel(category: categoryList);
  }
}
