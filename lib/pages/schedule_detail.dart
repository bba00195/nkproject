// #region Import
import 'dart:async';
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
import 'package:nkproject/model/conference_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/model/schedule_model.dart';
import 'package:nkproject/pages/meeting_detail.dart';
// #endregion

class ScheduleDetail extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;
  final int appoId;

  ScheduleDetail({
    required this.id,
    required this.password,
    required this.member,
    required this.appoId,
  });
  @override
  ScheduleDetailState createState() => new ScheduleDetailState();
}

class ScheduleDetailState extends State<ScheduleDetail> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;
  late int appoId;

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

  bool isUpdate = true;

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  var categoryValue = 1;

  List<int> categoryCodeList = [];
  List<String> categoryNameList = [];

  double _currentSliderValue = 0;

  int statusValue = 1;

  List<ScheduleDetailResponseModel> scheduleDetailList = [];

  String refUsers = '';
  String jabUsers = '';
  String conUsers = '';
  String meetCode = '';

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    appoId = widget.appoId;
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
    searchDetail();
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

  Future<void> searchDetail() async {
    List<String> sParam = [
      member.user.userId,
      appoId.toString(),
    ];
    await apiService.getSelect("SCHEDULE_LIST_APP_S2", sParam).then((value) {
      setState(() {
        if (value.detail.isNotEmpty) {
          scheduleDetailList = value.detail;
          titleTextEditController.text =
              scheduleDetailList.elementAt(0).subject;
          sujuNoTextEditController.text =
              scheduleDetailList.elementAt(0).orderNo;
          shipNoTextEditController.text =
              scheduleDetailList.elementAt(0).shipNo;
          selectedStartDate =
              DateTime.parse(scheduleDetailList.elementAt(0).starts);
          selectedEndDate =
              DateTime.parse(scheduleDetailList.elementAt(0).ends);
          _currentSliderValue = double.parse(
              scheduleDetailList.elementAt(0).appoPercent.toString());
          statusValue = scheduleDetailList.elementAt(0).appoState;
          contentTextEditController.text =
              scheduleDetailList.elementAt(0).contents;
          refUsers =
              scheduleDetailList.elementAt(0).refUsers.replaceAll(',', ' ');
          jabUsers =
              scheduleDetailList.elementAt(0).jabUser.replaceAll(',', ' ');
          conUsers =
              scheduleDetailList.elementAt(0).conUserId.replaceAll(',', ' ');
          meetCode = scheduleDetailList.elementAt(0).meetCode;
        } else {}
      });
    });
  }

  scheduleUpdate(
    String sSubject,
    DateTime dSDate,
    DateTime dEDate,
    int sCateId,
    int sAppoPercent,
    int sAppoState,
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

    String sSDate = DateFormat('yyyy-MM-dd 00:00:00.000').format(dSDate);
    String sEDate = DateFormat('yyyy-MM-dd 00:00:00.000').format(dEDate);

    if (sSubject == '') {
      show("제목은 필수 입력값입니다.");
      return;
    }

    if (sContents == '') {
      show("내용은 필수 입력값입니다.");
      return;
    }

    List<String> sParam = [
      appoId.toString(),
      sSubject,
      sSDate,
      sEDate,
      sCateId.toString(),
      sAppoPercent.toString(),
      sAppoState.toString(),
      sRegUserId,
      sContents,
      sOrderNo,
      sShipNo,
    ];
    await apiService.getUpdate("SCHEDULE_LIST_APP_U1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            showRoute("일정이 수정되었습니다.");
            isUpdate = true;
            searchDetail();
          }
        } else {
          show("수정에 실패하였습니다.");
        }
      });
    });
  }

  scheduleDelete(
    String sRegUserId,
  ) async {
    List<String> sParam = [
      appoId.toString(),
      sRegUserId,
    ];
    await apiService.getDelete("SCHEDULE_LIST_APP_D1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            show("일정이 삭제되었습니다.");
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
          }
        } else {
          show("삭제 실패하였습니다.");
        }
      });
    });
  }

  Future<void> searchCategory() async {
    List<String> sParam = [''];
    await apiService.getSelect("BASIC_CATEGORIES_S1", sParam).then((value) {
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
                          child: IgnorePointer(
                            ignoring: isUpdate,
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
            child: IgnorePointer(
              ignoring: isUpdate,
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
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: IgnorePointer(
                    ignoring: isUpdate,
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
                  child: IgnorePointer(
                    ignoring: isUpdate,
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
                        child: IgnorePointer(
                          ignoring: isUpdate,
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
                              DateFormat('yy. MM. dd')
                                  .format(selectedStartDate),
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
                        child: IgnorePointer(
                          ignoring: isUpdate,
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
                flex: 7,
                child: IgnorePointer(
                  ignoring: isUpdate,
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
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  _currentSliderValue.toString() + '%',
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
                            "진행",
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
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    color: Colors.grey[100],
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        refUsers,
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
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    color: Colors.grey[100],
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        jabUsers,
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
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    color: Colors.grey[100],
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        conUsers,
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
              ],
            ),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: (meetCode != '') ? true : false,
            child: Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  primary: Colors.indigo[600],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MeetingDetail(
                        id: id,
                        password: password,
                        member: member,
                        meetCode: meetCode,
                      ),
                    ),
                  );
                },
                child: Text(
                  '회의 상세 보기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: !isUpdate,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Color.fromRGBO(235, 235, 235, 1),
                ),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: IgnorePointer(
                ignoring: isUpdate,
                child: FlutterSummernote(
                  value: (scheduleDetailList.length > 0)
                      ? scheduleDetailList.elementAt(0).contents
                      : "",
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
              ),
            ),
          ),
          Visibility(
            visible: isUpdate,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Color.fromRGBO(235, 235, 235, 1),
                ),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: Html(data: contentTextEditController.text),
            ),
          ),
        ],
      ),
    );
  }

  btnSubimt() {
    if (isUpdate == true) {
      if (DateFormat('yyyy-MM-dd').format(selectedStartDate) !=
          DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        return Container();
      } else {
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
                    showDelete("일정을 삭제하시겠습니까?");
                  },
                  child: Text(
                    '삭제',
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
            ],
          ),
        );
      }
    } else {
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
                    isUpdate = true;
                    searchDetail();
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

                  await scheduleUpdate(
                    titleTextEditController.text,
                    selectedStartDate,
                    selectedEndDate,
                    categoryValue,
                    _currentSliderValue.toInt(),
                    statusValue,
                    member.user.userId,
                    sContent,
                    sujuNoTextEditController.text,
                    shipNoTextEditController.text,
                  );
                },
                child: Text(
                  '수정',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: (isUpdate) ? "일정 상세" : "일정 수정",
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

  showRoute(sMessage) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(sMessage),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () {
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
        }); // 비밀번호 불일치
  }

  showDelete(sMessage) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(sMessage),
            actions: [
              TextButton(
                child: Text("삭제"),
                onPressed: () async {
                  await scheduleDelete(member.user.userId);
                },
              ),
              TextButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }); // 비밀번호 불일치
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
