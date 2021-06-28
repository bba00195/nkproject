// #region Import
import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/model/meeting_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/pages/meeting_write.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// #endregion

class Meeting extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  Meeting({
    required this.id,
    required this.password,
    required this.member,
  });
  @override
  MeetingState createState() => new MeetingState();
}

class MeetingState extends State<Meeting> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  FocusNode nameFocusNode = FocusNode();
  final nameTextEditController = TextEditingController();
  GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();

  late int firstIndex;
  late int lastIndex;

  int subjectValue = 1;

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  int itemCount = 0;
  List<MeetingResponseModel> meetingValue = [];
  List<MeetingPlaceResponseModel> meetingPlaceValue = [];

  List<String> meetingDetailValue = [];
  List<bool> meetingVisibility = [];
  List<bool> meetingDetail = [];

  bool isOpen = false;

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    selectedStartDate = DateTime.now().add(Duration(days: -30));
    selectedEndDate = DateTime.now().add(Duration(days: 30));
    itemCount = 0;
    firstIndex = 1;
    lastIndex = 10;
    nameTextEditController.text = '';
    search();
    searchMeetingPlace();
    super.initState();
  }

  @override
  void dispose() {
    nameTextEditController.dispose();
    super.dispose();
  }

  search() {
    List<String> sParam = [
      DateFormat('yyyy-MM-dd').format(selectedStartDate),
      DateFormat('yyyy-MM-dd').format(selectedEndDate),
      nameTextEditController.text,
      firstIndex.toString(),
      lastIndex.toString(),
    ];
    apiService.getSelect("MEETING_S2", sParam).then((value) {
      setState(() {
        if (lastIndex == 10) {
          //  새로고침 및 검색 시
          meetingVisibility.clear();
          meetingDetail.clear();
          meetingDetailValue.clear();
          itemCount = 0;
        }
        if (value.meeting.isNotEmpty) {
          meetingValue = value.meeting;
          for (int i = itemCount; i < meetingValue.length; i++) {
            if ((member.user.name == meetingValue.elementAt(i).regName) ||
                (meetingValue
                    .elementAt(i)
                    .members
                    .contains(member.user.userId)) ||
                (member.user.authorId == "ROLE_ADMIN")) {
              meetingVisibility.add(true);
            } else {
              meetingVisibility.add(false);
            }
            meetingDetail.add(false);
            meetingDetailValue.add('');
          }
          itemCount = meetingValue.length;
        } else {
          itemCount = 0;
        }
      });
    });
  }

  searchMeetingDetail(String sMeetCode, int sSeqNo) {
    List<String> sParam = [sMeetCode];
    apiService.getSelect("MEETING_S3", sParam).then((value) {
      setState(() {
        if (value.detail.isNotEmpty) {
          meetingDetailValue[sSeqNo] = value.detail.elementAt(0).contents;
        }
      });
    });
  }

  searchMeetingPlace() {
    List<String> sParam = ['Y'];
    apiService.getSelect("MEETING_S5", sParam).then((value) {
      setState(() {
        if (value.meetingPlace.isNotEmpty) {
          meetingPlaceValue = value.meetingPlace;
        }
      });
    });
  }

  meetingDelete(String sMeetCode) {
    List<String> sParam = [
      member.user.userId,
      sMeetCode,
    ];
    apiService.getDelete("MEETING_LIST_APP_D1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            show("회의가 삭제되었습니다.");
            search();
          }
        } else {
          show("삭제에 실패하였습니다.");
        }
      });
    });
  }

  meetingPlaceList(String sMeetPlace) {
    for (int i = 0; i < meetingPlaceValue.length; i++) {
      if (sMeetPlace == meetingPlaceValue.elementAt(i).codeId) {
        return meetingPlaceValue.elementAt(i).codeBName;
      }
    }
  }

  searchPanel() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 40,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color.fromRGBO(230, 230, 230, 1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: subjectValue,
                      items: [
                        DropdownMenuItem(
                          child: AutoSizeText(
                            "제목",
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
                            "주최자",
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
                            "내용",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                          value: 3,
                        )
                      ],
                      onChanged: (value) {
                        subjectValue = int.parse(value.toString());
                      },
                      hint: Text("Select item"),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  height: 40,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Form(
                    key: nameFormKey,
                    child: TextField(
                      autofocus: false,
                      controller: nameTextEditController,
                      focusNode: nameFocusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.grey[400],
                          ), // clear text
                          onPressed: () {
                            nameTextEditController.clear();
                          },
                        ),
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
                        fontSize: 14,
                        fontFamily: 'NotoSansKR',
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.indigo[700],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      lastIndex = 10;
                      search();
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  margin: EdgeInsets.all(5),
                  child: AutoSizeText(
                    'To',
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
              Expanded(
                flex: 4,
                child: Container(
                  height: 40,
                  margin: EdgeInsets.all(5),
                  color: Colors.grey[100],
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
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MeetingWrite(
                          id: id,
                          password: password,
                          member: member,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    margin: EdgeInsets.all(5),
                    child: Icon(
                      Icons.add_circle_outline_sharp,
                      size: 30,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  meetingBody() {
    if (itemCount > 0) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < meetingValue.length; i++)
              meetingCard(
                  meetingValue.elementAt(i).meetCode,
                  meetingValue.elementAt(i).meetId,
                  meetingValue.elementAt(i).meetDate,
                  meetingValue.elementAt(i).meetName,
                  meetingValue.elementAt(i).meetPlace,
                  meetingValue.elementAt(i).status,
                  meetingValue.elementAt(i).sDate,
                  meetingValue.elementAt(i).eDate,
                  meetingValue.elementAt(i).appoId,
                  // meetingValue.elementAt(i).contents,
                  meetingValue.elementAt(i).name,
                  meetingValue.elementAt(i).departName,
                  meetingValue.elementAt(i).regName,
                  meetingValue.elementAt(i).meetRoom,
                  meetingValue.elementAt(i).meetDay,
                  meetingValue.elementAt(i).meetTime,
                  meetingValue.elementAt(i).members,
                  i)
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  meetingFuncDelete(String sMeetCode, int sStatus, String sRegName) {
    if (sStatus == 2) {
      return Container();
    } else {
      if ((sRegName == member.user.name) ||
          (member.user.authorId == 'ROLE_ADMIN')) {
        return InkWell(
          onTap: () {
            showMessage(sMeetCode);
          },
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              Icons.delete_forever,
              color: Colors.grey[400],
              size: 30,
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  meetingFuncUpdate(String sMeetCode, int sStatus, String sRegName) {
    if (sStatus == 2) {
      return Container();
    } else {
      if ((sRegName == member.user.name) ||
          (member.user.authorId == 'ROLE_ADMIN')) {
        return InkWell(
          onTap: () {
            showMessage(sMeetCode);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_circle,
              color: (sStatus == 1)
                  ? Color.fromRGBO(230, 58, 84, 0.8)
                  : ((sStatus == 2)
                      ? Color.fromRGBO(66, 91, 168, 0.8)
                      : Color.fromRGBO(0, 220, 15, 0.5)),
              size: 30,
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  meetingCard(
      String sMeetCode,
      String sMeetId,
      String sMeetDate,
      String sMeetName,
      String sMeetPlace,
      int sStatus,
      String sSDate,
      String sEDate,
      int sAppoId,
      // String sContents,
      String sName,
      String sDepartName,
      String sRegName,
      String sMeetRoom,
      String sMeetDay,
      int sMeetTime,
      String sMembers,
      int sSeqNo) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            offset: const Offset(0.0, 3.0),
            color: (sStatus == 1)
                ? Color.fromRGBO(230, 58, 84, 0.3)
                : ((sStatus == 2)
                    ? Color.fromRGBO(66, 91, 168, 0.5)
                    : Color.fromRGBO(0, 220, 15, 0.16)),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(5),
      child: Container(
        // margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: AutoSizeText(
                    sMeetName,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                    ),
                    minFontSize: 14,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: meetingFuncDelete(sMeetCode, sStatus, sRegName),
                ),
                Expanded(
                  flex: 1,
                  child: meetingFuncUpdate(sMeetCode, sStatus, sRegName),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: AutoSizeText(
                    '$sDepartName $sName',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKR',
                    ),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: AutoSizeText(
                    sMeetDate,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKR',
                    ),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      meetingPlaceList(sMeetPlace) != null
                          ? meetingPlaceList(sMeetPlace)
                          : '',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
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
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.schedule,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: AutoSizeText(
                      (sSDate != '' || sEDate != '') ? '$sSDate ~ $sEDate' : '',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Visibility(
              visible: meetingVisibility[sSeqNo],
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  child: Icon(
                    meetingDetail[sSeqNo]
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                    size: 36,
                  ),
                  onTap: () {
                    if (!meetingDetail[sSeqNo]) {
                      searchMeetingDetail(sMeetCode, sSeqNo);
                    }
                    setState(() {
                      for (int i = 0; i < meetingValue.length; i++) {
                        if (i != sSeqNo) {
                          meetingDetail[i] = false;
                        }
                      }
                      meetingDetail[sSeqNo] = !meetingDetail[sSeqNo];
                    });
                  },
                ),
              ),
            ),
            Visibility(
              visible: meetingDetail[sSeqNo],
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: AutoSizeText(
                              ' 내용',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'NotoSansKR',
                              ),
                              minFontSize: 12,
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: AutoSizeText(
                              '작성자 : ' + sName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'NotoSansKR',
                              ),
                              minFontSize: 12,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      child: Html(data: meetingDetailValue[sSeqNo]),
                      // AutoSizeText(
                      //   sContents,
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontFamily: 'NotoSansKR',
                      //   ),
                      //   minFontSize: 12,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "회의관리",
      ),
      drawer: NkDrawer(
        id: id,
        password: password,
        member: member,
        storage: storage,
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: () {
          setState(() {
            isOpen = false;
            lastIndex = 10;
            search();
          });
          _refreshController.refreshCompleted();
        },
        onLoading: () {
          setState(() {
            lastIndex += 10;
            search();
            _refreshController.loadComplete();
          });
          _refreshController.refreshCompleted();
        },
        child: GestureDetector(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                searchPanel(),
                SizedBox(height: 10),
                meetingBody(),
                SizedBox(height: 30),
              ],
            ),
          ),
          onTap: () {
            focusChange(context, nameFocusNode);
          },
        ),
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
        }); // 비밀번호 불일치
  }

  showMessage(String sMeetCode) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text("회의를 정말로 삭제하시겠습니까?"),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text("확인"),
              onPressed: () {
                meetingDelete(sMeetCode);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void focusChange(BuildContext context, FocusNode currentFocus) {
    currentFocus.unfocus(); //현재 FocusNode의 포커스를 지운다.
  }
}
