import 'package:http/http.dart' as http;
import 'package:nkproject/model/common_model.dart';
import 'package:nkproject/model/conference_model.dart';
import 'package:nkproject/model/employee_model.dart';
import 'dart:convert';

import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/model/meeting_model.dart';
import 'package:nkproject/model/schedule_model.dart';

class APIService {
  var url = Uri.parse('http://211.213.24.69/NK/DBHelper_secure.php');

  Future getSelect(String sFunctionName, List<String> sParam) async {
    var result;
    var sBody = jsonEncode(
        {"TYPE": "SELECT", "FUNCNAME": sFunctionName, "PARAMS": sParam});
    var headers = {'Content-Type': "application/json"};

    switch (sFunctionName) {
      case "BASIC_CATEGORIES_S1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = BasicCategorisResultModel.fromJson(json.decode(response.body));
        break;
      case "EMPLOYEELIST_S2":
        final response = await http.post(url, body: sBody, headers: headers);
        result = EmployeeResultModel.fromJson(json.decode(response.body));
        break;
      case "MEETING_S2":
        final response = await http
            .post(url, body: sBody, headers: headers)
            .catchError((error) {});
        result = MeetingResultModel.fromJson(json.decode(response.body));
        break;
      case "MEETING_S3":
        final response = await http.post(url, body: sBody, headers: headers);
        result = MeetingDetailResultModel.fromJson(json.decode(response.body));
        break;
      case "MEETING_S5":
        final response = await http.post(url, body: sBody, headers: headers);
        result = MeetingPlaceResultModel.fromJson(json.decode(response.body));
        break;
      case "LOGIN_S1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = LoginResultModel.fromJson(json.decode(response.body));
        break;
      case "SCHEDULE_LIST_APP_S1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = ScheduleListResultModel.fromJson(json.decode(response.body));
        break;
      case "SCHEDULE_LIST_APP_S2":
        final response = await http.post(url, body: sBody, headers: headers);
        result = ScheduleDetailResultModel.fromJson(json.decode(response.body));
        break;
      case "SEQUENCELIST_S1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = SequenceListResultModel.fromJson(json.decode(response.body));
        break;
      default:
        break;
    }
    return result;
  }

  Future getInsert(String sFunctionName, List<String> sParam) async {
    var result;
    var sBody = jsonEncode(
        {"TYPE": "INSERT", "FUNCNAME": sFunctionName, "PARAMS": sParam});
    var headers = {'Content-Type': "application/json"};

    switch (sFunctionName) {
      case "MEETING_LIST_APP_I1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "MEETING_MEMBER_LIST_APP_I1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "SCHEDULE_LIST_APP_I1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      default:
        break;
    }
    return result;
  }

  Future getUpdate(String sFunctionName, List<String> sParam) async {
    var result;
    var sBody = jsonEncode(
        {"TYPE": "UPDATE", "FUNCNAME": sFunctionName, "PARAMS": sParam});
    var headers = {'Content-Type': "application/json"};

    switch (sFunctionName) {
      case "LOGIN_U1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "MEETINGLIST_U6":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "SCHEDULE_LIST_APP_U1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "SEQUENCE_LIST_U1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      default:
        break;
    }
    return result;
  }

  Future getDelete(String sFunctionName, List<String> sParam) async {
    var result;
    var sBody = jsonEncode(
        {"TYPE": "DELETE", "FUNCNAME": sFunctionName, "PARAMS": sParam});
    var headers = {'Content-Type': "application/json"};

    switch (sFunctionName) {
      case "MEETING_LIST_APP_D1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      case "SCHEDULE_LIST_APP_D1":
        final response = await http.post(url, body: sBody, headers: headers);
        result = InsertResultModel.fromJson(json.decode(response.body));
        break;
      default:
        break;
    }
    return result;
  }
}

class InsertResponseModel {
  final String rsCode;
  final String rsMsg;

  InsertResponseModel({
    required this.rsCode,
    required this.rsMsg,
  });

  factory InsertResponseModel.fromJson(Map<String, dynamic> json) {
    return InsertResponseModel(
      rsCode: json['RS_CODE'] != null ? json['RS_CODE'] as String : "",
      rsMsg: json['RS_MSG'] != null ? json['RS_MSG'] as String : "",
    );
  }
}

class InsertResultModel {
  List<InsertResponseModel> result;

  InsertResultModel({required this.result});

  factory InsertResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<InsertResponseModel> resultList =
        list.map((i) => InsertResponseModel.fromJson(i)).toList();
    return InsertResultModel(result: resultList);
  }
}
