class ConferenceResponseModel {
  final String title;
  final String userName;
  final String dateTime;
  final String place;
  final String startTime;
  final String endTime;
  final String content;

  ConferenceResponseModel({
    required this.title,
    required this.userName,
    required this.dateTime,
    required this.place,
    required this.startTime,
    required this.endTime,
    required this.content,
  });

  factory ConferenceResponseModel.fromJson(Map<String, dynamic> json) {
    return ConferenceResponseModel(
      title: json['TITLE'] != null ? json['TITLE'] as String : "",
      userName: json['USERNAME'] != null ? json['USERNAME'] as String : "",
      dateTime: json['DATETIME'] != null ? json['DATETIME'] as String : "",
      place: json['PLACE'] != null ? json['PLACE'] as String : "",
      startTime: json['STARTTIME'] != null ? json['STARTTIME'] as String : "",
      endTime: json['ENDTIME'] != null ? json['ENDTIME'] as String : "",
      content: json['CONTENT'] != null ? json['CONTENT'] as String : "",
    );
  }
}

class ConferenceResultModel {
  List<ConferenceResponseModel> conference;

  ConferenceResultModel({required this.conference});

  factory ConferenceResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<ConferenceResponseModel> conferenceList =
        list.map((i) => ConferenceResponseModel.fromJson(i)).toList();
    return ConferenceResultModel(conference: conferenceList);
  }
}
