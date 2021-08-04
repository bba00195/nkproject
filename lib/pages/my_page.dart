import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/model/login_model.dart';

class MyPage extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  MyPage({
    required this.id,
    required this.password,
    required this.member,
  });

  @override
  MyPageState createState() => new MyPageState();
}

class MyPageState extends State<MyPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;
  APIService apiService = new APIService();

  GlobalKey<FormState> _passwordNowFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _passwordNewFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _passwordConfirmFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _telFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _EMailFormKey = GlobalKey<FormState>();
  final _passwordNowEditController = TextEditingController();
  final _passwordNewEditController = TextEditingController();
  final _passwordConfirmEditController = TextEditingController();
  final _telTextEditController = TextEditingController();
  final _EMailTextEditController = TextEditingController();
  late FocusNode telFocusNode;
  late FocusNode EMailFocusNode;
  late FocusNode passwordNowFocusNode;
  late FocusNode passwordNewFocusNode;
  late FocusNode passwordConfirmFocusNode;
  bool hidePassword = true; // Password Hide
  bool hidePasswordNow = true; // Password Hide
  bool hidePasswordNew = true; // Password Hide
  bool hidePasswordConfirm = true; // Password Hide

  late String pPassword;
  late int pPassLength;

  @override
  void initState() {
    super.initState();
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    pPassword = password;
    pPassLength = password.length;
    telFocusNode = FocusNode();
    EMailFocusNode = FocusNode();
    passwordNowFocusNode = FocusNode();
    passwordNewFocusNode = FocusNode();
    passwordConfirmFocusNode = FocusNode();
    _passwordNowEditController.text = "";
    _passwordNewEditController.text = "";
    _passwordConfirmEditController.text = "";
    _telTextEditController.text = member.user.tel;
    _EMailTextEditController.text = member.user.eMail;
  }

  @override
  void dispose() {
    super.dispose();
  }

  profileUpdate() async {
    List<String> sParam = [
      member.user.userId,
      _telTextEditController.text,
      _EMailTextEditController.text,
    ];
    await apiService.getUpdate("PROFILE_U1", sParam).then((value) {
      setState(() {
        if (value.result.isNotEmpty) {
          if (value.result.elementAt(0).rsCode == "E") {
            show(value.result.elementAt(0).rsMsg);
          } else {
            // member.user.password = pPassword;
            member.user.tel = _telTextEditController.text;
            member.user.eMail = _EMailTextEditController.text;
            show("정보가 수정되었습니다.");
          }
        } else {
          show("수정에 실패하였습니다.");
        }
      });
    });
  }

  myPageHead() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('resource/nk_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(64, 90, 168, 1),
                borderRadius: BorderRadius.circular(35)),
            width: 70,
            height: 70,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  myPageBody() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            '사용자명(한글)',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansKR',
              color: Colors.grey,
            ),
            minFontSize: 10,
            maxLines: 1,
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: AutoSizeText(
              member.user.name,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'NotoSansKR',
                color: Colors.black,
              ),
              minFontSize: 10,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '직책',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSansKR',
                        color: Colors.grey,
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: AutoSizeText(
                        member.user.position,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoSansKR',
                          color: Colors.black,
                        ),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 2, child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '성별',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSansKR',
                        color: Colors.grey,
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: AutoSizeText(
                        (member.user.sex == 'M') ? '남성' : '여성',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoSansKR',
                          color: Colors.black,
                        ),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          AutoSizeText(
            '전화번호',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansKR',
              color: Colors.grey,
            ),
            minFontSize: 10,
            maxLines: 1,
          ),
          Container(
            // height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Form(
              key: _telFormKey,
              child: TextField(
                controller: _telTextEditController,
                focusNode: telFocusNode,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
                  fillColor: Colors.transparent,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansKR',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(vertical: 5),
          //   width: MediaQuery.of(context).size.width,
          //   decoration: BoxDecoration(
          //     border: Border(
          //       bottom: BorderSide(
          //         color: Colors.grey,
          //         width: 1,
          //       ),
          //     ),
          //   ),
          //   child: AutoSizeText(
          //     member.user.tel,
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontFamily: 'NotoSansKR',
          //       color: Colors.black,
          //     ),
          //     minFontSize: 10,
          //     maxLines: 1,
          //   ),
          // ),
          SizedBox(height: 10),
          AutoSizeText(
            '이메일',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansKR',
              color: Colors.grey,
            ),
            minFontSize: 10,
            maxLines: 1,
          ),

          Container(
            // height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Form(
              key: _EMailFormKey,
              child: TextField(
                controller: _EMailTextEditController,
                focusNode: EMailFocusNode,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
                  fillColor: Colors.transparent,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansKR',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       '비밀번호',
          //       textAlign: TextAlign.left,
          //       style: TextStyle(
          //         color: Colors.grey,
          //         fontSize: 14,
          //         fontFamily: 'NotoSansKR',
          //       ),
          //     ),
          //     Container(
          //       padding: EdgeInsets.only(top: 5, bottom: 5, left: 3),
          //       width: MediaQuery.of(context).size.width,
          //       decoration: BoxDecoration(
          //         border: Border(
          //           bottom: BorderSide(
          //             width: 1.0,
          //           ),
          //         ),
          //       ),
          //       child: Row(
          //         children: [
          //           Expanded(
          //             child: InkWell(
          //               onTap: () {
          //                 showPassword();
          //               },
          //               child: Text(
          //                 hidePassword
          //                     ? (pPassword).replaceRange(
          //                         0, pPassLength, '•' * pPassLength)
          //                     : pPassword,
          //                 style: TextStyle(
          //                   color: Colors.black,
          //                   fontSize: 16,
          //                   fontFamily: 'NotoSansKR',
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //             ),
          //           ),
          //           InkWell(
          //             onTap: () {
          //               setState(() {
          //                 hidePassword = !hidePassword;
          //               });
          //             },
          //             child: Icon(
          //               hidePassword ? Icons.visibility_off : Icons.visibility,
          //               color: Colors.blue,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  showPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
          body: GestureDetector(
            onTap: () {
              passwordNowFocusNode.unfocus();
              passwordNewFocusNode.unfocus();
              passwordConfirmFocusNode.unfocus();
            },
            child: Center(
              child: Container(
                height: 350,
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      "비밀번호 변경",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            '현재 비밀번호',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Form(
                              key: _passwordNowFormKey,
                              child: TextField(
                                controller: _passwordNowEditController,
                                focusNode: passwordNowFocusNode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
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
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePasswordNow = !hidePasswordNow;
                                      });
                                    },
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.4),
                                    icon: Icon(hidePasswordNow
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                obscureText: hidePasswordNow,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            '변경 비밀번호',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Form(
                              key: _passwordNewFormKey,
                              child: TextField(
                                controller: _passwordNewEditController,
                                focusNode: passwordNewFocusNode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
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
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePasswordNew = !hidePasswordNew;
                                      });
                                    },
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.4),
                                    icon: Icon(hidePasswordNew
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                obscureText: hidePasswordNew,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            '비밀번호 확인',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'NotoSansKR',
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Form(
                              key: _passwordConfirmFormKey,
                              child: TextField(
                                controller: _passwordConfirmEditController,
                                focusNode: passwordConfirmFocusNode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
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
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePasswordConfirm =
                                            !hidePasswordConfirm;
                                      });
                                    },
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.4),
                                    icon: Icon(hidePasswordConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                obscureText: hidePasswordConfirm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 22),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5),
                              ),
                              primary: Colors.black54,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              _passwordNowEditController.text = "";
                              _passwordNewEditController.text = "";
                              _passwordConfirmEditController.text = "";
                              hidePasswordNow = true;
                              hidePasswordNew = true;
                              hidePasswordConfirm = true;
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
                        SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 22),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5),
                              ),
                              primary: Colors.indigo[900],
                            ),
                            onPressed: () {
                              if (_passwordNowEditController.text == "" ||
                                  _passwordNewEditController.text == "" ||
                                  _passwordConfirmEditController.text == "") {
                                show("비밀번호를 입력해주세요.");
                              } else {
                                if (_passwordNowEditController.text !=
                                    pPassword) {
                                  show("현재 비밀번호가 일치하지 않습니다.");
                                } else {
                                  if (_passwordNewEditController.text !=
                                      _passwordConfirmEditController.text) {
                                    show("변경 비밀번호가 일치하지 않습니다.");
                                  } else {
                                    if (pPassword ==
                                            _passwordNewEditController.text ||
                                        pPassword ==
                                            _passwordConfirmEditController
                                                .text) {
                                      show("비밀번호가 변경되지 않았습니다.");
                                    } else {
                                      setState(() {
                                        pPassword =
                                            _passwordNewEditController.text;
                                        pPassLength = pPassword.length;
                                        _passwordNowEditController.text = "";
                                        _passwordNewEditController.text = "";
                                        _passwordConfirmEditController.text =
                                            "";
                                      });
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                }
                              }
                            },
                            child: Text(
                              '변경',
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  btnUpdate() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 22),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5),
          ),
          primary: Colors.indigo[600],
        ),
        onPressed: () async {
          await profileUpdate();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "내 정보",
      ),
      drawer: NkDrawer(
        id: id,
        password: password,
        member: member,
        storage: storage,
      ),
      body: GestureDetector(
        onTap: () {
          telFocusNode.unfocus();
          EMailFocusNode.unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myPageHead(),
                SizedBox(height: 20),
                myPageBody(),
                SizedBox(height: 5),
                btnUpdate(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
