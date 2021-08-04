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
import 'package:nkproject/model/comment_model.dart';
import 'package:nkproject/model/meeting_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/pages/meeting_detail.dart';
import 'package:nkproject/pages/meeting_write.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// #endregion

class Comment extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  Comment({
    required this.id,
    required this.password,
    required this.member,
  });
  @override
  CommentState createState() => new CommentState();
}

class CommentState extends State<Comment> {
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;

  APIService apiService = new APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late int firstIndex;
  late int lastIndex;

  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  int itemCount = 0;
  List<CommentResponseModel> commentValue = [];

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
    search();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  search() {
    List<String> sParam = [
      DateFormat('yyyy-MM-dd').format(selectedStartDate),
      DateFormat('yyyy-MM-dd').format(selectedEndDate),
      member.user.userId,
      firstIndex.toString(),
      lastIndex.toString(),
    ];
    apiService.getSelect("COMMENT_LIST_APP_S1", sParam).then((value) {
      setState(() {
        if (lastIndex == 10) {
          itemCount = 0;
        }
        if (value.comment.isNotEmpty) {
          commentValue = value.comment;
          itemCount = commentValue.length;
        } else {
          itemCount = 0;
        }
      });
    });
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
        ],
      ),
    );
  }

  commentOutPut() {
    return Container(
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
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: new BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.subject,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          commentValue.elementAt(sCommentSeq).subject,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: AutoSizeText(
                          commentValue.elementAt(sCommentSeq).departName +
                              " " +
                              commentValue.elementAt(sCommentSeq).userName,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.content_paste,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Html(
                            data: commentValue.elementAt(sCommentSeq).comment),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
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
                  flex: 4,
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
                Expanded(flex: 5, child: Container()),
              ],
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
        menuName: "코멘트 관리",
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
                commentOutPut(),
                SizedBox(height: 30),
              ],
            ),
          ),
          onTap: () {},
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
}
