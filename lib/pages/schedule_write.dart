// #region Import
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
import 'package:intl/intl.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/model/conference_model.dart';
import 'package:nkproject/model/employee_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
// #endregion

class ScheduleWrite extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  ScheduleWrite({
    required this.id,
    required this.password,
    required this.member,
  });
  @override
  ScheduleWriteState createState() => new ScheduleWriteState();
}

class ScheduleWriteState extends State<ScheduleWrite> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FlutterSummernoteState> summernoteKey = new GlobalKey();
  FocusNode titleFocusNode = FocusNode();
  FocusNode ownerFocusNode = FocusNode();
  FocusNode makerFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  FocusNode sujuNoFocusNode = FocusNode();
  FocusNode shipNoFocusNode = FocusNode();
  FocusNode refFocusNode = FocusNode();
  FocusNode jabFocusNode = FocusNode();
  FocusNode conFocusNode = FocusNode();
  final titleTextEditController = TextEditingController();
  final ownerTextEditController = TextEditingController();
  final makerTextEditController = TextEditingController();
  final contentTextEditController = TextEditingController();
  final sujuNoTextEditController = TextEditingController();
  final shipNoTextEditController = TextEditingController();
  final refTextEditController = TextEditingController();
  final jabTextEditController = TextEditingController();
  final conTextEditController = TextEditingController();
  GlobalKey<FormState> titleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> ownerFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> makerFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> contentFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> sujuNoFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> shipNoFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> refFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> jabFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> conFormKey = GlobalKey<FormState>();

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  var categoryValue = 1;

  List<int> categoryCodeList = [];
  List<String> categoryNameList = [];

  double _currentSliderValue = 0;

  int statusValue = 0;

  String conUserNameList = '';
  List<String> conUserNameValue = [];
  List<String> conUserIdValue = [];
  List<String> conUserHpTokenValue = [];

  String jabUserNameList = '';
  List<String> jabUserNameValue = [];
  List<String> jabUserIdValue = [];
  List<String> jabUserHpTokenValue = [];

  String refUserNameList = '';
  List<String> refUserNameValue = [];
  List<String> refUserIdValue = [];
  List<String> refUserHpTokenValue = [];

  String constructFCMPayload(String token, String title) {
    return jsonEncode({
      'registration_ids': [token],
      'notification': {
        'title': '[NK 일정 참조 알림]',
        'body': title + '에 참조자로 지정되었습니다.',
      },
    });
  }

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    titleTextEditController.text = '';
    ownerTextEditController.text = '';
    makerTextEditController.text = '';
    contentTextEditController.text = '';
    sujuNoTextEditController.text = '';
    shipNoTextEditController.text = '';
    refTextEditController.text = '';
    jabTextEditController.text = '';
    conTextEditController.text = '';
    searchCategory();
    super.initState();
  }

  @override
  void dispose() {
    titleTextEditController.dispose();
    ownerTextEditController.dispose();
    makerTextEditController.dispose();
    contentTextEditController.dispose();
    sujuNoTextEditController.dispose();
    shipNoTextEditController.dispose();
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

  conUserList(String nameList, List<String> idValue, List<String> nameValue,
      List<String> hpTokenValue) {
    setState(() {
      conUserNameList = nameList;
      conUserNameValue = nameValue;
      conUserIdValue = idValue;
      conUserHpTokenValue = hpTokenValue;
    });
  }

  jabUserList(String nameList, List<String> idValue, List<String> nameValue,
      List<String> hpTokenValue) {
    setState(() {
      jabUserNameList = nameList;
      jabUserNameValue = nameValue;
      jabUserIdValue = idValue;
      jabUserHpTokenValue = hpTokenValue;
    });
  }

  refUserList(String nameList, List<String> idValue, List<String> nameValue,
      List<String> hpTokenValue) {
    setState(() {
      refUserNameList = nameList;
      refUserNameValue = nameValue;
      refUserIdValue = idValue;
      refUserHpTokenValue = hpTokenValue;
    });
  }

  scheduleInsert(
    String sSubject,
    DateTime dSDate,
    DateTime dEDate,
    int sCateId,
    String sRegUserId,
    String sContents,
    String sOrderNo,
    String sShipNo,
  ) async {
    titleFocusNode.unfocus();
    ownerFocusNode.unfocus();
    makerFocusNode.unfocus();
    contentFocusNode.unfocus();
    sujuNoFocusNode.unfocus();
    shipNoFocusNode.unfocus();
    refFocusNode.unfocus();
    jabFocusNode.unfocus();
    conFocusNode.unfocus();

    if (sSubject == '') {
      show("제목은 필수 입력값입니다.");
      return;
    }

    // if (sContents == '') {
    //   show("내용은 필수 입력값입니다.");
    //   return;
    // }

    String sSDate = DateFormat('yyyy-MM-dd 00:00:00.000').format(dSDate);
    String sEDate = DateFormat('yyyy-MM-dd 00:00:00.000').format(dEDate);

    String conUserId = '';
    String jabUserId = '';

    for (int i = 0; i < conUserIdValue.length; i++) {
      if (i == 0) {
        conUserId += '[' + conUserIdValue[i] + ']';
      } else {
        conUserId += ',[' + conUserIdValue[i] + ']';
      }
    }

    for (int i = 0; i < jabUserIdValue.length; i++) {
      if (i == 0) {
        jabUserId += '[' + jabUserIdValue[i] + ']';
      } else {
        jabUserId += ',[' + jabUserIdValue[i] + ']';
      }
    }

    List<String> sParam = [
      sSubject,
      sSDate,
      sEDate,
      sCateId.toString(),
      sRegUserId,
      sContents,
      sOrderNo,
      sShipNo,
      conUserId,
      jabUserId
    ];
    await apiService.getInsert("SCHEDULE_LIST_APP_I1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            showRoute("일정이 등록되었습니다.");
          }
        } else {
          show("등록에 실패하였습니다.");
        }
      });
    });
  }

  searchCategory() {
    List<String> sParam = [''];
    apiService.getSelect("BASIC_CATEGORIES_S1", sParam).then((value) {
      setState(() {
        if (value.category.isNotEmpty) {
          for (int i = 0; i < value.category.length; i++) {
            categoryCodeList.add(value.category.elementAt(i).cateId);
            categoryNameList.add(value.category.elementAt(i).category);
          }
        }
      });
    });
  }

  category(int value) {
    for (int i = 0; i < categoryNameList.length; i++) {
      if (categoryCodeList[i] == value) {
        return categoryNameList[i];
      }
    }
  }

  conferenceForm() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: Color.fromRGBO(235, 235, 235, 1),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              value: categoryValue,
                              items: categoryCodeList.map(
                                (value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: AutoSizeText(
                                      category(value),
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
                                  categoryValue = int.parse(value.toString());
                                });
                              },
                              hint: Text("Select Project"),
                            ),
                          ),
                        ),
                      ),
                    ],
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
          // Container(
          //   alignment: Alignment.center,
          //   height: 40,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 8,
          //         child: Container(
          //           alignment: Alignment.centerLeft,
          //           height: 40,
          //           margin: EdgeInsets.only(right: 5),
          //           padding: EdgeInsets.symmetric(horizontal: 5),
          //           color: Colors.grey[100],
          //           child: AutoSizeText(
          //             "2020년 사업기획실 사업목표 달성.",
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontFamily: 'NotoSansKR',
          //               fontWeight: FontWeight.w600,
          //             ),
          //             minFontSize: 10,
          //             maxLines: 1,
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         flex: 2,
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //             padding: EdgeInsets.symmetric(horizontal: 5),
          //             shape: new RoundedRectangleBorder(
          //               borderRadius: new BorderRadius.circular(5),
          //             ),
          //             primary: Colors.blue[600],
          //           ),
          //           onPressed: () {},
          //           child: AutoSizeText(
          //             "핵심업무검색",
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontFamily: 'NotoSansKR',
          //               fontWeight: FontWeight.w600,
          //             ),
          //             minFontSize: 10,
          //             maxLines: 1,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10),
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
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: Form(
                    key: sujuNoFormKey,
                    child: TextField(
                      autofocus: false,
                      controller: sujuNoTextEditController,
                      focusNode: sujuNoFocusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
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
                        hintText: "수주번호",
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
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
                  child: Form(
                    key: shipNoFormKey,
                    child: TextField(
                      autofocus: false,
                      controller: shipNoTextEditController,
                      focusNode: shipNoFocusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
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
                        hintText: "호선",
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 40,
                  padding: EdgeInsets.all(3),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          '계획일',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: TextButton(
                          style: ButtonStyle(),
                          onPressed: () {
                            Future<DateTime?> startDate = showDatePicker(
                              context: context,
                              initialDate: selectedStartDate, // 초깃값
                              firstDate: DateTime(2018), // 시작일
                              lastDate: DateTime(2030), // 마지막일
                            );
                            startDate.then((dateTime) {
                              setState(() {
                                if (dateTime != null) {
                                  selectedStartDate = dateTime!;
                                } else {
                                  dateTime = selectedStartDate;
                                }
                              });
                            });
                          },
                          child: AutoSizeText(
                            DateFormat('yy. MM. dd').format(selectedStartDate),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ),
                      ),
                    ],
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
                  height: 40,
                  padding: EdgeInsets.all(3),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          '완료일',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: TextButton(
                          style: ButtonStyle(),
                          onPressed: () {
                            Future<DateTime?> endDate = showDatePicker(
                              context: context,
                              initialDate: selectedEndDate, // 초깃값
                              firstDate: DateTime(2018), // 시작일
                              lastDate: DateTime(2030), // 마지막일
                            );
                            endDate.then((dateTime) {
                              setState(() {
                                if (dateTime != null) {
                                  selectedEndDate = dateTime!;
                                } else {
                                  dateTime = selectedEndDate;
                                }
                              });
                            });
                          },
                          child: AutoSizeText(
                            DateFormat('yy. MM. dd').format(selectedEndDate),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AutoSizeText(
                  '진행율',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
              Expanded(
                flex: 8,
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: AutoSizeText(
                    '진행상태',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontFamily: 'NotoSansKR',
                    ),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Color.fromRGBO(235, 235, 235, 1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: statusValue,
                      items: [
                        DropdownMenuItem(
                          child: AutoSizeText(
                            "시작안함",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: AutoSizeText(
                            "진행중",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: AutoSizeText(
                            "완료",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                          value: 2,
                        ),
                        DropdownMenuItem(
                          child: AutoSizeText(
                            "지연",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                          value: -1,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          statusValue = int.parse(value.toString());
                        });
                      },
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Container(),
              // ),
              // Expanded(
              //   flex: 4,
              //   child: Container(
              //     alignment: Alignment.center,
              //     height: 40,
              //     child: Form(
              //       key: refFormKey,
              //       child: TextField(
              //         autofocus: false,
              //         controller: refTextEditController,
              //         focusNode: refFocusNode,
              //         decoration: InputDecoration(
              //           contentPadding: EdgeInsets.all(10.0),
              //           enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //               color: Colors.transparent,
              //             ),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //               color: Colors.transparent,
              //             ),
              //           ),
              //           filled: true,
              //           fillColor: Colors.grey[100],
              //           hintText: "권한자",
              //         ),
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontFamily: 'NotoSansKR',
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 10),

          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: AutoSizeText(
                      '권한자',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return EmployeeList(refUserList);
                          },
                        );
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      color: Colors.grey[100],
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          refUserNameList,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: AutoSizeText(
                      '작업자',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return EmployeeList(jabUserList);
                          },
                        );
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      color: Colors.grey[100],
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          jabUserNameList,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: AutoSizeText(
                      '참조자',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return EmployeeList(conUserList);
                          },
                        );
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      color: Colors.grey[100],
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          conUserNameList,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
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
            // child: Form(
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

  btnSubimt() {
    return Container(
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
                await scheduleInsert(
                  titleTextEditController.text,
                  selectedStartDate,
                  selectedEndDate,
                  categoryValue,
                  member.user.userId,
                  sContent,
                  sujuNoTextEditController.text,
                  shipNoTextEditController.text,
                );
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
    // #region Widget

    // #region Body
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "일정등록",
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
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              conferenceForm(),
              SizedBox(height: 10),
              btnSubimt(),
              SizedBox(height: 10),
            ],
          ),
        ),
        onTap: () {
          titleFocusNode.unfocus();
          ownerFocusNode.unfocus();
          makerFocusNode.unfocus();
          contentFocusNode.unfocus();
          sujuNoFocusNode.unfocus();
          shipNoFocusNode.unfocus();
          refFocusNode.unfocus();
          jabFocusNode.unfocus();
          conFocusNode.unfocus();
        },
      ),
    );
    // #endregion
  }
  // #region Event
  //
  //
  //
  //
  //final

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
                  for (int i = 0; i < conUserHpTokenValue.length; i++) {
                    await sendPushMessage(
                        conUserHpTokenValue[i], titleTextEditController.text);
                  }
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Home(
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
        });
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
}

class EmployeeList extends StatefulWidget {
  EmployeeList(this.func);
  Function func;

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

  late String conUserString = '';

  List<String> employeeUserId = [];
  List<String> employeeUserName = [];
  List<String> employeeHpToken = [];

  @override
  void initState() {
    func = widget.func;
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
                setState(() {
                  employeeUserId.add(sUserId);
                  employeeUserName.add(sName);
                  employeeHpToken.add(sHptoken);
                  conUserString += sName + ', ';
                });
                // if (isMember) {
                //   func(sDepartNameTwo, sName, sUserId);
                // } else {
                //   func(sDepartNameTwo, sName, sPosition, sUserId, sDepartCode,
                //       sEMail, sMemberSeq, sHptoken);
                // }
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
                Container(
                  alignment: Alignment.centerLeft,
                  height: 25,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: AutoSizeText(
                            conUserString,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                            ),
                            minFontSize: 10,
                            maxLines: 1,
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
                              primary: Colors.blue[400],
                            ),
                            onPressed: () {
                              setState(() {
                                func(conUserString, employeeUserId,
                                    employeeUserName, employeeHpToken);
                                Navigator.of(context).pop();
                              });
                            },
                            child: memberPopupHead("확인"),
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
