// #region Import
import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/model/conference_model.dart';
import 'package:nkproject/model/login_model.dart';
// #endregion

class BoardWrite extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  BoardWrite({
    required this.id,
    required this.password,
    required this.member,
  });

  @override
  BoardWriteState createState() => new BoardWriteState();
}

class BoardWriteState extends State<BoardWrite> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
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

  int categoryValue = 1;
  double _currentSliderValue = 0;

  int statusValue = 1;

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
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
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: AutoSizeText(
                    "공지사항",
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
                    key: makerFormKey,
                    child: TextField(
                      autofocus: false,
                      controller: makerTextEditController,
                      focusNode: makerFocusNode,
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
                        hintText: "작성자",
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
          SizedBox(height: 10),
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
                          '시작일',
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
                          '목표일',
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
            child: Form(
              key: contentFormKey,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: false,
                controller: contentTextEditController,
                focusNode: contentFocusNode,
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
                  fillColor: Colors.white,
                  hintText: "내용을 입력해 주세요.",
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansKR',
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
              onPressed: () {},
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
        menuName: "공지사항 등록",
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
              SizedBox(height: 20),
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

  Future show(sMessage) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert(sMessage);
        }); // 비밀번호 불일치
  }

  Widget alert(String sContent) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(sContent),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('확인'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
