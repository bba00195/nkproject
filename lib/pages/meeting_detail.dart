// #region Import
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
import 'package:intl/intl.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/model/employee_model.dart';
import 'package:nkproject/model/meeting_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/pages/employee_list.dart';
import 'package:nkproject/pages/meeting.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
// #endregion

class MeetingDetail extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;
  final String meetCode;

  MeetingDetail({
    required this.id,
    required this.password,
    required this.member,
    required this.meetCode,
  });
  @override
  MeetingDetailState createState() => new MeetingDetailState();
}

class MeetingDetailState extends State<MeetingDetail> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;
  late String meetCode;

  late String pDepartNameTwo;
  late String pName;
  late String pId;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FlutterSummernoteState> summernoteKey = new GlobalKey();
  final GlobalKey<FlutterSummernoteState> commentKey = new GlobalKey();

  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  final titleTextEditController = TextEditingController();
  final contentTextEditController = TextEditingController();
  GlobalKey<FormState> titleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> contentFormKey = GlobalKey<FormState>();

  List<FocusNode> attendFocusList = [];
  List<TextEditingController> attendTextEditController = [];
  List<GlobalKey<FormState>> attendFormKey = [];

  late DateTime selectedDate;
  late DateTime selectedTime;

  var placeValue = 'A';

  List<MeetingDetailResponseModel> meetingDetail = [];
  List<MeetingMemberResponseModel> meetingMemberList = [];

  List<String> placeCodeList = [];
  List<String> placeNameList = [];

  List<String> memberDepartValue = [];
  List<String> memberNameValue = [];
  List<String> memberPositionValue = [];
  List<String> memberIdValue = [];
  List<String> memberDepartCodeValue = [];
  List<String> memberEMailValue = [];
  List<String> meetMemberCodeValue = [];
  List<String> memberHpTokenValue = [];

  late String sMeetCode = '';
  late String sMeetMemberCode = '';

  late String rsMsg;

  List<int> attendValue = [];
  List<int> agreeValue = [];
  bool isUpdate = true;

  int sStatus = 0;

  String detailHpToken = "";

  List<MeetingCommentResponseModel> commentValue = [];

  FocusNode commentFocusNode = FocusNode();
  final commentTextEditController = TextEditingController();
  GlobalKey<FormState> commentFormKey = GlobalKey<FormState>();

  String commentConstructFCMPayload(
      String token, String meetName, String sName) {
    return jsonEncode({
      'registration_ids': [token],
      'notification': {
        'title': '[NK 회의 코멘트 알림]',
        'body': sName + "님이 " + meetName + '에 코멘트를 남겼습니다.',
      },
    });
  }

  String constructFCMPayload(String token, String meetName) {
    return jsonEncode({
      'registration_ids': [token],
      'notification': {
        'title': '[NK 회의 참석 알림]',
        'body': meetName + '에 참석자로 지정되었습니다.',
      },
    });
  }

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    meetCode = widget.meetCode;

    pDepartNameTwo = member.user.departName;
    pName = member.user.name;
    pId = member.user.userId;

    selectedDate = DateTime.now();
    selectedTime = DateTime.parse(
        DateTime.now().toString().substring(0, 10) + ' 09:00:00.000');
    searchMeetingPlace();
    searchMeetingDetail();
    searchMeetingMember();
    searchMeetingComment();
    memberDepartValue.add('');
    memberNameValue.add('');
    memberPositionValue.add('');
    memberIdValue.add('');
    memberDepartCodeValue.add('');
    memberEMailValue.add('');
    meetMemberCodeValue.add('');
    memberHpTokenValue.add('');
    super.initState();
  }

  @override
  void dispose() {
    titleTextEditController.dispose();
    contentTextEditController.dispose();
    commentTextEditController.dispose();
    for (int i = 0; i < meetingMemberList.length; i++) {
      attendTextEditController[i].dispose();
    }

    super.dispose();
  }

  commentDelete(
    String sMeetCode,
    String sCommentCode,
  ) async {
    List<String> sParam = [
      sMeetCode,
      sCommentCode,
    ];
    await apiService.getDelete("MEETING_COMMENT_APP_D1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            show("코멘트가 삭제되었습니다.");
            setState(() {
              isUpdate = true;
              searchMeetingDetail();
              searchMeetingMember();
              searchMeetingComment();
            });
          }
        } else {
          show("삭제 실패하였습니다.");
        }
      });
    });
  }

  commentInsert(
    String sMeetCode,
    String sDepartCode,
    String sRegId,
    String sDepartName,
    String sName,
    String sComment,
  ) async {
    titleFocusNode.unfocus();
    contentFocusNode.unfocus();
    commentFocusNode.unfocus();

    List<String> sParam = [
      sMeetCode,
      sDepartCode,
      sRegId,
      sDepartName,
      sName,
      sComment,
    ];
    await apiService.getInsert("MEETING_COMMENT_I1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            commentSendPushMessage(
                detailHpToken, titleTextEditController.text, sName);
            show("코멘트가 등록되었습니다.");
            setState(() {
              isUpdate = true;
              searchMeetingDetail();
              searchMeetingMember();
              searchMeetingComment();
              // Navigator.of(context).pop();
            });
          }
        } else {
          show("등록에 실패하였습니다.");
        }
      });
    });
  }

  searchMeetingComment() async {
    List<String> sParam = [meetCode];
    await apiService.getSelect("MEETING_COMMENT_S1", sParam).then((value) {
      setState(() {
        if (value.meetingComment.isNotEmpty) {
          commentValue = value.meetingComment;
        } else {}
      });
    });
  }

  meetingUpdate(
      String sMeetId,
      DateTime sDate,
      DateTime sTime,
      String sMeetName,
      String sMeetPlace,
      String sContents,
      String sRegId) async {
    String sDateTime = DateFormat('yyyy-MM-dd').format(sDate) +
        " " +
        DateFormat('hh:mm').format(sTime);

    if (sMeetName == '') {
      show("제목은 필수 입력값입니다.");
      return;
    }

    if (sContents == '') {
      show("내용은 필수 입력값입니다.");
      return;
    }

    List<String> sParam = [
      meetCode,
      sMeetId,
      sDateTime,
      sMeetName,
      sMeetPlace,
      sContents,
      sRegId
    ];
    await apiService.getUpdate("MEETING_LIST_APP_U1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            // showRoute("회의가 등록되었습니다.");
          }
        } else {
          show("등록에 실패하였습니다.");
        }
      });
    });
  }

  meetingMemberUpdate(String sMeetMemberCode, String sMeetCode, String sRegId,
      int sAttend, int sAgree, String sComment) async {
    List<String> sParam = [
      sMeetMemberCode,
      sMeetCode,
      sRegId,
      sAttend.toString(),
      sAgree.toString(),
      sComment
    ];
    await apiService
        .getUpdate("MEETING_MEMBER_LIST_APP_U1", sParam)
        .then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
            rsMsg = "E";
            return;
          } else {
            rsMsg = "S";
          }
        }
      });
    });
  }

  meetingStart(String sMeetCode, String sRegId) async {
    List<String> sParam = [sMeetCode, sRegId];
    await apiService.getUpdate("MEETING_LIST_APP_U2", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
            rsMsg = "E";
            return;
          } else {
            rsMsg = "S";
          }
        }
      });
    });
  }

  meetingEnd(String sMeetCode, String sRegId) async {
    List<String> sParam = [
      sMeetCode,
      sRegId,
    ];
    await apiService.getUpdate("MEETING_LIST_APP_U3", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
            rsMsg = "E";
            return;
          } else {
            rsMsg = "S";
          }
        }
      });
    });
  }

  searchMeetingDetail() async {
    List<String> sParam = [meetCode];
    await apiService.getSelect("MEETING_S3", sParam).then((value) {
      setState(() {
        if (value.detail.isNotEmpty) {
          meetingDetail = value.detail;
          titleTextEditController.text = meetingDetail.elementAt(0).meetName;
          selectedDate = DateTime.parse(meetingDetail.elementAt(0).meetDay);
          selectedTime = DateTime.parse(meetingDetail.elementAt(0).meetDate);

          pDepartNameTwo = meetingDetail.elementAt(0).departName;
          pName = meetingDetail.elementAt(0).regName;
          placeValue = meetingDetail.elementAt(0).meetPlace;
          contentTextEditController.text = meetingDetail.elementAt(0).contents;
          sStatus = meetingDetail.elementAt(0).status;
          detailHpToken = meetingDetail.elementAt(0).hpToken;
        }
      });
    });
  }

  searchMeetingMember() async {
    List<String> sParam = [meetCode];
    await apiService.getSelect("MEETING_S1_APP", sParam).then((value) {
      setState(() {
        if (value.meetingMember.isNotEmpty) {
          attendValue = [];
          agreeValue = [];
          meetingMemberList = value.meetingMember;
          for (int i = 0; i < meetingMemberList.length; i++) {
            attendValue.add(meetingMemberList.elementAt(i).attend);
            agreeValue.add(meetingMemberList.elementAt(i).agree);
            // attendTextEditController.add(TextEditingController());
            // attendTextEditController[i].text =
            //     meetingMemberList.elementAt(i).comment;
          }

          attendFocusList = [
            for (int i = 0; i < meetingMemberList.length; i++) FocusNode(),
          ];

          attendTextEditController = [
            for (int i = 0; i < meetingMemberList.length; i++)
              TextEditingController(),
          ];

          attendFormKey = [
            for (int i = 0; i < meetingMemberList.length; i++)
              GlobalKey<FormState>(),
          ];

          for (int i = 0; i < meetingMemberList.length; i++) {
            attendTextEditController[i].text =
                meetingMemberList.elementAt(i).comment;
          }
        }
      });
    });
  }

  Future<void> commentSendPushMessage(
      String sHpToken, String sMeetName, String sName) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: commentConstructFCMPayload(sHpToken, sMeetName, sName),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAA4KwvSS8:APA91bGpMfrrYpop-z11KJcE47TOth_CDaapN5jBiUfqevutE0zhBmvrhcjjWDybjlUvd7eEDI7sCgVf5WSGknYy_lX1-j8V2luAaPNa44bqdawnXpdaXfQRy3MqFrEpjHxo8ein7ZWn',
        },
      );
      final result = (json.decode(response.body));
      print(result);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendPushMessage(String sHpToken, String sMeetName) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: constructFCMPayload(sHpToken, sMeetName),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAA4KwvSS8:APA91bGpMfrrYpop-z11KJcE47TOth_CDaapN5jBiUfqevutE0zhBmvrhcjjWDybjlUvd7eEDI7sCgVf5WSGknYy_lX1-j8V2luAaPNa44bqdawnXpdaXfQRy3MqFrEpjHxo8ein7ZWn',
        },
      );
      final result = (json.decode(response.body));
      print(result);
    } catch (e) {
      print(e);
    }
  }

  selectEmployee(String departNameTwoValue, String nameValue, String idValue) {
    setState(() {
      pDepartNameTwo = departNameTwoValue;
      pName = nameValue;
      pId = idValue;
    });
  }

  selectMemberList(
      String departNameTwoValue,
      String nameValue,
      String positionValue,
      String idValue,
      String departCodeValue,
      String eMailValue,
      int seqValue,
      String hpTokenValue) {
    setState(() {
      memberDepartValue[seqValue] = departNameTwoValue;
      memberNameValue[seqValue] = nameValue;
      memberPositionValue[seqValue] = positionValue;
      memberIdValue[seqValue] = idValue;
      memberDepartCodeValue[seqValue] = departCodeValue;
      memberEMailValue[seqValue] = eMailValue;
      memberHpTokenValue[seqValue] = hpTokenValue;
    });
  }

  searchMeetingPlace() async {
    List<String> sParam = ['Y'];
    await apiService.getSelect("MEETING_S5", sParam).then((value) {
      setState(() {
        if (value.meetingPlace.isNotEmpty) {
          for (int i = 0; i < value.meetingPlace.length; i++) {
            placeCodeList.add(value.meetingPlace.elementAt(i).codeId);
            placeNameList.add(value.meetingPlace.elementAt(i).codeBName);
          }
        }
      });
    });
  }

  place(String value) {
    for (int i = 0; i < placeNameList.length; i++) {
      if (placeCodeList[i] == value) {
        return placeNameList[i];
      }
    }
  }

  showTimePicker(BuildContext ctx) {
    DateTime time =
        DateTime.now().add(Duration(minutes: 0 - DateTime.now().minute % 10));
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: Text(
                    '닫기',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text('등록'),
                  onPressed: () {
                    selectedTime = time;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                minuteInterval: 10,
                initialDateTime: selectedTime,
                onDateTimeChanged: (valueTime) {
                  setState(() {
                    time = valueTime;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  meetingForm() {
    return IgnorePointer(
      ignoring: isUpdate,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              child: Form(
                key: titleFormKey,
                child: TextField(
                  autofocus: false,
                  controller: titleTextEditController,
                  focusNode: titleFocusNode,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "제목",
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSansKR',
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: 40,
                    child: Icon(
                      Icons.calendar_today_outlined,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    height: 40,
                    child: AutoSizeText(
                      "일시",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.all(5),
                    color: Colors.grey[100],
                    child: TextButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        Future<DateTime?> startDate = showDatePicker(
                          context: context,
                          initialDate: selectedDate, // 초깃값
                          firstDate: DateTime(2018), // 시작일
                          lastDate: DateTime(2030), // 마지막일
                        );
                        startDate.then((dateTime) {
                          setState(() {
                            if (dateTime != null) {
                              selectedDate = dateTime!;
                            } else {
                              dateTime = selectedDate;
                            }
                          });
                        });
                      },
                      child: AutoSizeText(
                        DateFormat('yyyy. MM. dd').format(selectedDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.all(5),
                    color: Colors.grey[100],
                    child: TextButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        showTimePicker(context);
                      },
                      child: AutoSizeText(
                        DateFormat('HH:mm').format(selectedTime),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return EmployeeList(selectEmployee, true, 0);
                          },
                        );
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 40,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                pDepartNameTwo + ' ' + pName,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                ),
                                minFontSize: 10,
                                maxLines: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 40,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                              member.user.name,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontFamily: 'NotoSansKR',
                              ),
                              minFontSize: 10,
                              maxLines: 1,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Color.fromRGBO(235, 235, 235, 1),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        value: placeValue,
                        items: placeCodeList.map(
                          (value) {
                            return DropdownMenuItem(
                              value: value,
                              child: AutoSizeText(
                                place(value),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w600,
                                ),
                                minFontSize: 10,
                                maxLines: 1,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            placeValue = value.toString();
                          });
                        },
                        hint: Text("Select item"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Color.fromRGBO(235, 235, 235, 1),
                ),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: (isUpdate == true)
                  ? Html(
                      data: (meetingDetail.length > 0)
                          ? meetingDetail.elementAt(0).contents
                          : '')
                  : FlutterSummernote(
                      value: meetingDetail.elementAt(0).contents,
                      key: summernoteKey,
                      showBottomToolbar: false,
                      customToolbar: """
              [
                ['style', ['bold', 'italic', 'underline', 'clear']],
                ['font', ['strikethrough', 'superscript', 'subscript']],
                ['font', ['fontsize', 'fontname']],
                ['color', ['forecolor', 'backcolor']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['height', ['height']],
                ['view', ['fullscreen']]
              ]
        """,
                    ),
              //  HtmlEditor(
              //   hint: "Your text here...",
              //   //value: "text content initial, if any",
              //   key: contentFormKey,
              // ),
              //     Form(
              //   key: contentFormKey,
              //   child: TextField(
              //     keyboardType: TextInputType.multiline,
              //     maxLines: null,
              //     autofocus: false,
              //     controller: contentTextEditController,
              //     focusNode: contentFocusNode,
              //     decoration: InputDecoration(
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //           color: Colors.transparent,
              //         ),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //           color: Colors.transparent,
              //         ),
              //       ),
              //       filled: true,
              //       fillColor: Colors.white,
              //       hintText: "내용을 입력해 주세요.",
              //     ),
              //     style: TextStyle(
              //       fontSize: 16,
              //       fontFamily: 'NotoSansKR',
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  memberHead(String headName) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: AutoSizeText(
        headName,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14, fontFamily: 'NotoSansKR', color: Colors.white),
        minFontSize: 8,
        maxLines: 1,
      ),
    );
  }

  memberRowText(String value, TextAlign align) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: AutoSizeText(
        value,
        textAlign: align,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'NotoSansKR',
          color: Colors.grey[700],
        ),
        minFontSize: 9,
        maxLines: 1,
      ),
    );
  }

  meetingMember() {
    return Container(
      child: Column(
        children: [
          Visibility(
            visible: false,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(flex: 8, child: Container()),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          memberDepartValue.add('');
                          memberNameValue.add('');
                          memberPositionValue.add('');
                          memberIdValue.add('');
                          memberDepartCodeValue.add('');
                          memberEMailValue.add('');
                          meetMemberCodeValue.add('');
                          memberHpTokenValue.add('');
                        });
                      },
                      child: Container(
                        height: 25,
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        // padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: new BorderRadius.circular(3),
                        ),
                        child: AutoSizeText(
                          "추가",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansKR',
                            color: Colors.white,
                          ),
                          minFontSize: 9,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 30,
              color: Colors.cyan[700],
              child: Row(
                children: [
                  Visibility(
                    visible: false,
                    child: Expanded(flex: 2, child: memberHead("구분")),
                  ),
                  Expanded(flex: 2, child: memberHead("소속")),
                  Expanded(flex: 2, child: memberHead("성명")),
                  Expanded(flex: 2, child: memberHead("직위")),
                  Visibility(
                    visible: false,
                    child: Expanded(flex: 2, child: memberHead("기능")),
                  ),
                  Visibility(
                    visible: true,
                    child: Expanded(flex: 2, child: memberHead("참석")),
                  ),
                  Visibility(
                    visible: true,
                    child: Expanded(flex: 2, child: memberHead("미참사유")),
                  ),
                  Visibility(
                    visible: true,
                    child: Expanded(flex: 2, child: memberHead("동의")),
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child:
          Container(
            child: Column(
              children: [
                for (int i = 0; i < meetingMemberList.length; i++)
                  memberListCard(i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  memberListCard(int sMemberSeq) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          Visibility(
            visible: false,
            child: Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return EmployeeList(
                            selectMemberList, false, sMemberSeq);
                      },
                    );
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(3),
                  ),
                  child: AutoSizeText(
                    "검색",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    minFontSize: 9,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: memberRowText(
                  meetingMemberList.elementAt(sMemberSeq).departName,
                  TextAlign.center)),
          Expanded(
              flex: 2,
              child: memberRowText(meetingMemberList.elementAt(sMemberSeq).name,
                  TextAlign.center)),
          Expanded(
              flex: 2,
              child: memberRowText(
                  meetingMemberList.elementAt(sMemberSeq).position,
                  TextAlign.center)),
          Visibility(
            visible: false,
            child: Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sMemberSeq == 0) {
                      memberDepartValue[sMemberSeq] = '';
                      memberNameValue[sMemberSeq] = '';
                      memberPositionValue[sMemberSeq] = '';
                      memberIdValue[sMemberSeq] = '';
                      memberDepartCodeValue[sMemberSeq] = '';
                      memberEMailValue[sMemberSeq] = '';
                      memberHpTokenValue[sMemberSeq] = '';
                    } else {
                      memberDepartValue.removeAt(sMemberSeq);
                      memberNameValue.removeAt(sMemberSeq);
                      memberPositionValue.removeAt(sMemberSeq);
                      memberIdValue.removeAt(sMemberSeq);
                      memberDepartCodeValue.removeAt(sMemberSeq);
                      memberEMailValue.removeAt(sMemberSeq);
                      memberHpTokenValue.removeAt(sMemberSeq);
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(3),
                  ),
                  child: AutoSizeText(
                    "삭제",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKR',
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    minFontSize: 9,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3),
              child: IgnorePointer(
                ignoring: isUpdate,
                child: Switch(
                  value: (attendValue[sMemberSeq] == 1) ? true : false,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        attendValue[sMemberSeq] = 1;
                      } else {
                        attendValue[sMemberSeq] = 2;
                      }
                    });
                  },
                  activeTrackColor: Colors.lightBlueAccent[200],
                  activeColor: Colors.blue,
                ),
              ),
            ),
          ),
          // Visibility(
          //   visible: !isUpdate,
          //   child: Expanded(
          //     flex: 2,
          //     child: DropdownButtonHideUnderline(
          //       child: DropdownButton(
          //         value: attendValue[sMemberSeq],
          //         items: [
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 0,
          //           ),
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "참석",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 1,
          //           ),
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "미참석",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 2,
          //           ),
          //         ],
          //         onChanged: (value) {
          //           setState(() {
          //             attendValue[sMemberSeq] = int.parse(value.toString());
          //             if (attendValue[sMemberSeq] != 2) {
          //               attendTextEditController[sMemberSeq].text = "";
          //               attendFocusList[sMemberSeq].unfocus();
          //             }
          //           });
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          Visibility(
            visible: true,
            child: Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                child: IgnorePointer(
                  ignoring:
                      ((isUpdate == false) && (attendValue[sMemberSeq] == 2))
                          ? false
                          : true,
                  child: Form(
                    key: attendFormKey[sMemberSeq],
                    child: TextField(
                      autofocus: false,
                      controller: attendTextEditController[sMemberSeq],
                      focusNode: attendFocusList[sMemberSeq],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(2),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'NotoSansKR',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3),
              child: IgnorePointer(
                ignoring: isUpdate,
                child: Switch(
                  value: (agreeValue[sMemberSeq] == 1) ? true : false,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        agreeValue[sMemberSeq] = 1;
                      } else {
                        agreeValue[sMemberSeq] = 2;
                      }
                    });
                  },
                  activeTrackColor: Colors.lightBlueAccent[200],
                  activeColor: Colors.blue,
                ),
              ),
            ),
          ),
          // Visibility(
          //   visible: isUpdate,
          //   child: Expanded(
          //     flex: 2,
          //     child: Container(
          //       margin: EdgeInsets.symmetric(horizontal: 3),
          //       child: AutoSizeText(
          //         (meetingMemberList.elementAt(sMemberSeq).agree == 1)
          //             ? '동의'
          //             : (meetingMemberList.elementAt(sMemberSeq).agree == 2)
          //                 ? '비동의'
          //                 : '',
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontFamily: 'NotoSansKR',
          //           color: Colors.grey[700],
          //         ),
          //         minFontSize: 9,
          //         maxLines: 1,
          //       ),
          //     ),
          //   ),
          // ),
          // Visibility(
          //   visible: !isUpdate,
          //   child: Expanded(
          //     flex: 2,
          //     child: DropdownButtonHideUnderline(
          //       child: DropdownButton(
          //         value: agreeValue[sMemberSeq],
          //         items: [
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 0,
          //           ),
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "동의",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 1,
          //           ),
          //           DropdownMenuItem(
          //             child: AutoSizeText(
          //               "미동의",
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'NotoSansKR',
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               minFontSize: 10,
          //               maxLines: 1,
          //             ),
          //             value: 2,
          //           ),
          //         ],
          //         onChanged: (value) {
          //           setState(() {
          //             agreeValue[sMemberSeq] = int.parse(value.toString());
          //           });
          //         },
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  btnSubimt() {
    if (isUpdate) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.lightGreen,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: Text(
                  '닫기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Visibility(
              visible: (sStatus == 1) ? false : true,
              child: Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                    ),
                    primary: Colors.indigo[600],
                  ),
                  onPressed: () {
                    setState(() {
                      isUpdate = false;
                    });
                  },
                  child: Text(
                    '수정하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: (sStatus == 1) ? false : true,
              child: Expanded(
                flex: 1,
                child: Container(),
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.blue,
                ),
                onPressed: () async {
                  if (sStatus == 1) {
                    setState(() {
                      isUpdate = false;
                    });
                  } else {
                    await meetingStart(meetCode, member.user.userId);
                    await searchMeetingDetail();
                    await searchMeetingMember();
                    setState(() {
                      isUpdate = false;
                    });
                  }
                },
                child: Text(
                  (sStatus == 1) ? '진행' : '시작',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.lightGreen,
                ),
                onPressed: () {
                  setState(() {
                    searchMeetingDetail();
                    searchMeetingMember();
                    isUpdate = true;
                    // Navigator.of(context).pop();
                  });
                },
                child: Text(
                  '닫기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.indigo[600],
                ),
                onPressed: () async {
                  if (sStatus == 1) {
                    var _etEditor = summernoteKey.currentState!.getText();
                    String sContent = '';
                    _etEditor.then((value) {
                      if (value.isNotEmpty) {
                        sContent = value.toString();
                      }
                    });
                    for (int i = 0; i < meetingMemberList.length; i++) {
                      if ((attendValue[i] == 0) || (agreeValue[i] == 0)) {
                        show("참석, 동의 여부를 선택해주세요.");
                        return;
                      } else {
                        if ((attendValue[i] == 2) &&
                            (attendTextEditController[i].text == "")) {
                          show("미참석 사유를 작성해주세요.");
                          return;
                        }
                      }
                    }

                    await meetingUpdate(
                        pId,
                        selectedDate,
                        selectedTime,
                        titleTextEditController.text,
                        placeValue.toString(),
                        sContent,
                        member.user.userId);
                    for (int i = 0; i < meetingMemberList.length; i++) {
                      await meetingMemberUpdate(
                          meetingMemberList.elementAt(i).memberCode,
                          meetingMemberList.elementAt(i).meetCode,
                          member.user.userId,
                          attendValue[i],
                          agreeValue[i],
                          attendTextEditController[i].text);
                    }
                    await meetingEnd(meetCode, member.user.userId);
                    await show("요청하신 처리가 완료되었습니다.");

                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Meeting(
                          id: id,
                          password: password,
                          member: member,
                        ),
                      ),
                    );
                  } else {
                    var _etEditor = summernoteKey.currentState!.getText();
                    String sContent = '';
                    _etEditor.then((value) {
                      if (value.isNotEmpty) {
                        sContent = value.toString();
                      }
                    });
                    await meetingUpdate(
                        pId,
                        selectedDate,
                        selectedTime,
                        titleTextEditController.text,
                        placeValue.toString(),
                        sContent,
                        member.user.userId);
                    for (int i = 0; i < meetingMemberList.length; i++) {
                      await meetingMemberUpdate(
                          meetingMemberList.elementAt(i).memberCode,
                          meetingMemberList.elementAt(i).meetCode,
                          member.user.userId,
                          attendValue[i],
                          agreeValue[i],
                          attendTextEditController[i].text);
                    }
                    if (rsMsg == "S") {
                      showRoute("회의가 수정되었습니다.");
                    }
                  }
                },
                child: Text(
                  (sStatus == 1) ? '종료' : '수정',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  commentInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ListTile(
            title: Container(
              child: AutoSizeText(
                "※ 회의 코멘트",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'NotoSansKR',
                ),
                minFontSize: 10,
                maxLines: 1,
              ),
            ),
          ),
          Visibility(
            visible: !isUpdate,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: FlutterSummernote(
                height: 300,
                hint: "코멘트를 입력하세요.",
                key: commentFormKey,
                showBottomToolbar: false,
                customToolbar: """
              [
                ['style', ['bold', 'italic', 'underline', 'clear']],
                ['font', ['strikethrough', 'superscript', 'subscript']],
                ['font', ['fontsize', 'fontname']],
                ['color', ['forecolor', 'backcolor']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['height', ['height']],
                ['view', ['fullscreen']]
              ]
        """,
              ),
              // Form(
              //   key: commentFormKey,
              //   child: TextField(
              //     keyboardType: TextInputType.multiline,
              //     autofocus: false,
              //     controller: commentTextEditController,
              //     focusNode: commentFocusNode,
              //     decoration: InputDecoration(
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //           color: Colors.transparent,
              //         ),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //           color: Colors.transparent,
              //         ),
              //       ),
              //       filled: true,
              //       fillColor: Colors.grey[100],
              //       hintText: "코멘트를 입력하세요",
              //     ),
              //     style: TextStyle(
              //       fontSize: 14,
              //       fontFamily: 'NotoSansKR',
              //     ),
              //   ),
              // ),
            ),
          ),
          Visibility(
            visible: !isUpdate,
            child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.blue,
                ),
                onPressed: () async {
                  if (commentTextEditController.text == '') {
                    return;
                  }

                  await commentInsert(
                    meetCode,
                    member.user.departCode,
                    member.user.userId,
                    member.user.departName,
                    member.user.name,
                    commentTextEditController.text,
                  );
                },
                child: AutoSizeText(
                  "등록",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600),
                  minFontSize: 10,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  commentOutPut() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          for (int i = 0; i < commentValue.length; i++) commentListCard(i),
        ],
      ),
    );
  }

  commentListCard(int sCommentSeq) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: new BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(5),
                  child: AutoSizeText(
                    commentValue.elementAt(sCommentSeq).departName +
                        " " +
                        commentValue.elementAt(sCommentSeq).name,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child:
                      Html(data: commentValue.elementAt(sCommentSeq).comment),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: AutoSizeText(
                      commentValue.elementAt(sCommentSeq).regDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 5),
                //     child: AutoSizeText(
                //       "코멘트 추가",
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontFamily: 'NotoSansKR',
                //         fontWeight: FontWeight.w600,
                //       ),
                //       minFontSize: 10,
                //       maxLines: 1,
                //     ),
                //   ),
                // ),
                Visibility(
                  visible: (commentValue.elementAt(sCommentSeq).userId ==
                          member.user.userId)
                      ? true
                      : false,
                  child: Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        await commentDelete(meetCode,
                            commentValue.elementAt(sCommentSeq).commentCode);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: AutoSizeText(
                          "삭제",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: (commentValue.elementAt(sCommentSeq).userId ==
                          member.user.userId)
                      ? false
                      : true,
                  child: Expanded(flex: 2, child: Container()),
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(flex: 1, child: Container()),
              ],
            ),
          ),
        ],
      ),

      // Row(
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Container(
      //         child: AutoSizeText(
      //           commentValue.elementAt(sCommentSeq).departName +
      //               " " +
      //               commentValue.elementAt(sCommentSeq).name,
      //           style: TextStyle(
      //             fontSize: 14,
      //             fontFamily: 'NotoSansKR',
      //           ),
      //           minFontSize: 10,
      //           maxLines: 1,
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 2,
      //       child: Container(
      //         child: AutoSizeText(
      //           commentValue.elementAt(sCommentSeq).regDate,
      //           style: TextStyle(
      //             fontSize: 14,
      //             fontFamily: 'NotoSansKR',
      //           ),
      //           minFontSize: 10,
      //           maxLines: 1,
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 4,
      //       child: Container(
      //         child: AutoSizeText(
      //           commentValue.elementAt(sCommentSeq).comment,
      //           style: TextStyle(
      //             fontSize: 14,
      //             fontFamily: 'NotoSansKR',
      //           ),
      //           minFontSize: 10,
      //           maxLines: 1,
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Container(
      //         child: ElevatedButton(
      //           style: ElevatedButton.styleFrom(
      //             padding: EdgeInsets.symmetric(horizontal: 10),
      //             shape: new RoundedRectangleBorder(
      //               borderRadius: new BorderRadius.circular(5),
      //             ),
      //             primary: Colors.indigo[600],
      //           ),
      //           onPressed: () {},
      //           child: AutoSizeText(
      //             "삭제",
      //             style: TextStyle(
      //               fontSize: 14,
      //               fontFamily: 'NotoSansKR',
      //             ),
      //             minFontSize: 10,
      //             maxLines: 1,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Container(
      //         child: ElevatedButton(
      //           style: ElevatedButton.styleFrom(
      //             padding: EdgeInsets.symmetric(horizontal: 10),
      //             shape: new RoundedRectangleBorder(
      //               borderRadius: new BorderRadius.circular(5),
      //             ),
      //             primary: Colors.indigo[600],
      //           ),
      //           onPressed: () {},
      //           child: AutoSizeText(
      //             "코멘트 추가",
      //             style: TextStyle(
      //               fontSize: 14,
      //               fontFamily: 'NotoSansKR',
      //             ),
      //             minFontSize: 10,
      //             maxLines: 1,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "회의상세",
      ),
      drawer: NkDrawer(
        id: id,
        password: password,
        member: member,
        storage: storage,
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      body: GestureDetector(
        child: SingleChildScrollView(
          // padding: EdgeInsets.symmetric(
          //     horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              meetingForm(),
              SizedBox(height: 10),
              meetingMember(),
              SizedBox(height: 10),
              btnSubimt(),
              SizedBox(height: 10),
              commentInput(),
              commentOutPut(),
              SizedBox(height: 30),
            ],
          ),
        ),
        onTap: () {
          titleFocusNode.unfocus();
          contentFocusNode.unfocus();
          commentFocusNode.unfocus();
          for (int i = 0; i < meetingMemberList.length; i++) {
            attendFocusList[i].unfocus();
          }
        },
      ),
    );
  }

  show(sMessage) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(sMessage),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  showRoute(sMessage) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(sMessage),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () async {
                  for (int i = 0; i < memberHpTokenValue.length; i++) {
                    await sendPushMessage(
                        memberHpTokenValue[i], titleTextEditController.text);
                  }
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Meeting(
                        id: id,
                        password: password,
                        member: member,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }); // 비밀번호 불일치
  }
}

class EmployeeList extends StatefulWidget {
  EmployeeList(this.func, this.isMember, this.sMemberSeq);
  Function func;
  final bool isMember;
  final int sMemberSeq;

  @override
  EmployeeListState createState() => new EmployeeListState();
}

class EmployeeListState extends State<EmployeeList> {
  late Function func;

  late String id;
  late String password;
  late UserManager member;

  APIService apiService = new APIService();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  FocusNode keyWordFocusNode = FocusNode();
  final keyWordTextEditController = TextEditingController();
  GlobalKey<FormState> keyWordFormKey = GlobalKey<FormState>();

  late String pDepartNameTwo;
  late String pName;
  late String pUserId;

  late int firstIndex;
  late int lastIndex;

  int itemCount = 0;
  List<EmployeeResponseModel> employeeListValue = [];
  late bool isMember;
  late int sMemberSeq;

  @override
  void initState() {
    func = widget.func;
    isMember = widget.isMember;
    sMemberSeq = widget.sMemberSeq;
    firstIndex = 1;
    lastIndex = 20;
    searchEmployee();
    super.initState();
  }

  @override
  void dispose() {
    keyWordTextEditController.dispose();
    super.dispose();
  }

  searchEmployee() {
    List<String> sParam = [
      '',
      '',
      keyWordTextEditController.text,
      firstIndex.toString(),
      lastIndex.toString(),
    ];
    apiService.getSelect("EMPLOYEELIST_S2", sParam).then((value) {
      setState(() {
        if (value.employee.isNotEmpty) {
          employeeListValue = value.employee;
        }
      });
    });
  }

  memberPopupHead(String headName) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: AutoSizeText(
        headName,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14, fontFamily: 'NotoSansKR', color: Colors.white),
        minFontSize: 8,
        maxLines: 1,
      ),
    );
  }

  employeeRowText(String value, TextAlign align) {
    return AutoSizeText(
      value,
      textAlign: align,
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'NotoSansKR',
        color: Colors.grey[700],
      ),
      minFontSize: 9,
      maxLines: 1,
    );
  }

  employeeCard(
      String sDepartName,
      String sPosition,
      String sName,
      String sDepartNameTwo,
      String sUserId,
      String sDepartCode,
      String sEMail,
      String sHptoken) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 35,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              flex: 5, child: employeeRowText(sDepartName, TextAlign.left)),
          Expanded(
              flex: 1, child: employeeRowText(sPosition, TextAlign.center)),
          Expanded(flex: 2, child: employeeRowText(sName, TextAlign.center)),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (isMember) {
                  func(sDepartNameTwo, sName, sUserId);
                } else {
                  func(sDepartNameTwo, sName, sPosition, sUserId, sDepartCode,
                      sEMail, sMemberSeq, sHptoken);
                }
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: new BorderRadius.circular(3),
                ),
                child: AutoSizeText(
                  "선택",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'NotoSansKR',
                    color: Colors.white,
                  ),
                  minFontSize: 9,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
      body: GestureDetector(
        onTap: () {
          keyWordFocusNode.unfocus();
        },
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.only(bottom: 15),
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:
                                Icon(Icons.settings, color: Colors.cyan[400]),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: AutoSizeText(
                            "직원 검색",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'NotoSansKR',
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: Container(
                              child: Icon(Icons.close, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Form(
                            key: keyWordFormKey,
                            child: TextField(
                              autofocus: false,
                              controller: keyWordTextEditController,
                              focusNode: keyWordFocusNode,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                hintText: "이름을 입력하세요.",
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSansKR',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5),
                              ),
                              primary: Colors.indigo[600],
                            ),
                            onPressed: () {
                              searchEmployee();
                            },
                            child: memberPopupHead("검색"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    color: Colors.cyan[700],
                    child: Row(
                      children: [
                        Expanded(flex: 5, child: memberPopupHead("부서")),
                        Expanded(flex: 1, child: memberPopupHead("직급")),
                        Expanded(flex: 2, child: memberPopupHead("성명")),
                        Expanded(flex: 1, child: memberPopupHead("선택")),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: _refreshController,
                    onRefresh: () {
                      setState(() {
                        lastIndex = 20;
                        keyWordTextEditController.text = '';
                        searchEmployee();
                      });
                      _refreshController.refreshCompleted();
                    },
                    onLoading: () {
                      setState(() {
                        lastIndex += 20;
                        searchEmployee();
                        _refreshController.loadComplete();
                      });
                      _refreshController.refreshCompleted();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < employeeListValue.length; i++)
                            employeeCard(
                                employeeListValue.elementAt(i).departName,
                                employeeListValue.elementAt(i).position,
                                employeeListValue.elementAt(i).name,
                                employeeListValue.elementAt(i).departNameTwo,
                                employeeListValue.elementAt(i).userId,
                                employeeListValue.elementAt(i).departCode,
                                employeeListValue.elementAt(i).eMail,
                                employeeListValue.elementAt(i).hpToken),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
