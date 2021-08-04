// #region Import
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as prefix;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
// import 'package:html_editor/html_editor.dart';
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
import 'package:tuple/tuple.dart';
// #endregion

class MeetingWrite extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  MeetingWrite({
    required this.id,
    required this.password,
    required this.member,
  });
  @override
  MeetingWriteState createState() => new MeetingWriteState();
}

class MeetingWriteState extends State<MeetingWrite> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;

  late String pDepartNameTwo;
  late String pName;
  late String pId;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FlutterSummernoteState> summernoteKey = new GlobalKey();

  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  final titleTextEditController = TextEditingController();
  final contentTextEditController = TextEditingController();
  GlobalKey<FormState> titleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> contentFormKey = GlobalKey<FormState>();

  prefix.QuillController controller = prefix.QuillController.basic();

  late DateTime selectedDate;
  late DateTime selectedTime;

  var placeValue = 'A';

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

    pDepartNameTwo = member.user.departName;
    pName = member.user.name;
    pId = member.user.userId;

    selectedDate = DateTime.now();
    selectedTime = DateTime.parse(
        DateTime.now().toString().substring(0, 10) + ' 09:00:00.000');
    searchMeetingPlace();
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
    super.dispose();
  }

  Future<void> sendPushMessage(String sHpToken, String sMeetName) async {
    // if (member.user.token == null) {
    //   print('Unable to send FCM message, no token exists.');
    //   return;
    // }

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

  searchMeetingPlace() {
    List<String> sParam = ['Y'];
    apiService.getSelect("MEETING_S5", sParam).then((value) {
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

  selectMeetCodeSequence() async {
    List<String> sParam = ['MEETING_ID'];
    await apiService.getSelect("SEQUENCELIST_S1", sParam).then((value) {
      setState(() {
        if (value.sequence.isNotEmpty) {
          sMeetCode = (value.sequence.elementAt(0).nextId).toString();
          sMeetCode = sMeetCode.padLeft(12, '0');
          sMeetCode = "MT_" + sMeetCode;
        }
      });
    });
  }

  selectMeetMemberCodeSequence() async {
    List<String> sParam = ['MEETING_MEMBER_ID'];
    await apiService.getSelect("SEQUENCELIST_S1", sParam).then((value) {
      setState(() {
        if (value.sequence.isNotEmpty) {
          sMeetMemberCode = (value.sequence.elementAt(0).nextId).toString();
          sMeetMemberCode = sMeetMemberCode.padLeft(12, '0');
          sMeetMemberCode = "MM_" + sMeetMemberCode;
          print(sMeetMemberCode);
        }
      });
    });
  }

  // updateSequence(String sTableName) {
  //   List<String> sParam = [sTableName];
  //   apiService.getUpdate("SEQUENCE_LIST_U1", sParam).then((value) {
  //     setState(() {
  //       if (value.result.isNotEmpty) {
  //         if (value.result.elementAt(0).rsCode == "E") {
  //           show(value.result.elementAt(0).rsMsg);
  //         } else {}
  //       } else {
  //         show("등록에 실패하였습니다.");
  //       }
  //     });
  //   });
  // }

  meetingInsert(
      String sMeetId,
      DateTime sDate,
      DateTime sTime,
      String sMeetName,
      String sMeetPlace,
      String sContents,
      String sRegId) async {
    titleFocusNode.unfocus();
    contentFocusNode.unfocus();

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
      sMeetCode,
      sMeetId,
      sDateTime,
      sMeetName,
      sMeetPlace,
      sContents,
      sRegId
    ];
    await apiService.getInsert("MEETING_LIST_APP_I1", sParam).then((value) {
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

  meetingMemberInsert(
      String sMeetMemberCode,
      String sMeetCode,
      String sDepartCode,
      String sUserId,
      String sDepartName,
      String sMemberName,
      String sPosition,
      String sEMail,
      String sRegId) async {
    List<String> sParam = [
      '', //schMembercode INSERT는 되지 않지만 프로시저 매개변수가 있음
      sMeetMemberCode,
      sMeetCode,
      sDepartCode,
      sUserId,
      sDepartName,
      sMemberName,
      sPosition,
      sEMail,
      sRegId
    ];
    await apiService
        .getInsert("MEETING_MEMBER_LIST_APP_I1", sParam)
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
    return Container(
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
            // constraints: BoxConstraints(
            //   minHeight: MediaQuery.of(context).size.height * 0.3,
            // ),
            child: FlutterSummernote(
              hint: "내용을 입력해주세요.",
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
            // Column(
            //   children: [
            //     prefix.QuillToolbar.basic(
            //       controller: controller,
            //       showBoldButton: true,
            //       showItalicButton: true,
            //       showUnderLineButton: true,
            //       showStrikeThrough: true,
            //       showColorButton: true,
            //       showBackgroundColorButton: true,
            //       showClearFormat: false,
            //       showHeaderStyle: true,
            //       showListNumbers: true,
            //       showListBullets: true,
            //       showListCheck: true,
            //       showCodeBlock: true,
            //       showQuote: true,
            //       showIndent: false,
            //       showLink: false,
            //       showHistory: false,
            //       showHorizontalRule: false,
            //       multiRowsDisplay: false,
            //     ),
            //     prefix.QuillEditor(
            //       controller: controller,
            //       scrollController: ScrollController(),
            //       scrollable: true,
            //       focusNode: contentFocusNode,
            //       autoFocus: false,
            //       readOnly: false,
            //       placeholder: '내용을 입력해주세요.',
            //       expands: false,
            //       padding: EdgeInsets.all(5),
            //     ),
            //   ],
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
          Container(
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
          ListTile(
            title: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 30,
              color: Colors.cyan[700],
              child: Row(
                children: [
                  Expanded(flex: 2, child: memberHead("구분")),
                  Expanded(flex: 2, child: memberHead("소속")),
                  Expanded(flex: 2, child: memberHead("성명")),
                  Expanded(flex: 2, child: memberHead("직위")),
                  Expanded(flex: 2, child: memberHead("기능")),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child:
          Container(
            child: Column(
              children: [
                for (int i = 0; i < memberDepartValue.length; i++)
                  memberListCard(memberDepartValue[i], memberNameValue[i],
                      memberPositionValue[i], i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  memberListCard(
      String sDepartName, String sName, String sPosition, int sMemberSeq) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 25,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                setState(() {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return EmployeeList(selectMemberList, false, sMemberSeq);
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
          Expanded(
              flex: 2, child: memberRowText(sDepartName, TextAlign.center)),
          Expanded(flex: 2, child: memberRowText(sName, TextAlign.center)),
          Expanded(flex: 2, child: memberRowText(sPosition, TextAlign.center)),
          Expanded(
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
        ],
      ),
    );
  }

  btnSubimt() {
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
                  Navigator.of(context).pop();
                });
              },
              child: Text(
                '취소',
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
                var _etEditor = summernoteKey.currentState!.getText();
                String sContent = '';
                await _etEditor.then((value) {
                  if (value.isNotEmpty) {
                    sContent = value.toString();
                    print(value.toString());
                  }
                });
                await selectMeetCodeSequence();
                await meetingInsert(
                    pId,
                    selectedDate,
                    selectedTime,
                    titleTextEditController.text,
                    placeValue.toString(),
                    sContent,
                    member.user.userId);
                if (memberDepartValue.length > 0) {
                  for (int i = 0; i < memberDepartValue.length; i++) {
                    if (memberDepartValue[i] != '') {
                      await selectMeetMemberCodeSequence();
                      await meetingMemberInsert(
                          sMeetMemberCode,
                          sMeetCode,
                          memberDepartCodeValue[i],
                          memberIdValue[i],
                          memberDepartValue[i],
                          memberNameValue[i],
                          memberPositionValue[i],
                          memberEMailValue[i],
                          member.user.userId);
                    }
                  }
                  if (rsMsg == "S") {
                    showRoute("회의가 등록되었습니다.");
                  } else {
                    showRoute("회의가 등록되었습니다.");
                  }
                }
              },
              child: Text(
                '등록',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "회의등록",
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
            ],
          ),
        ),
        onTap: () {
          titleFocusNode.unfocus();
          contentFocusNode.unfocus();
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
