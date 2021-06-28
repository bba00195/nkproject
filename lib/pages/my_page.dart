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

  @override
  void initState() {
    super.initState();
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
  }

  @override
  void dispose() {
    super.dispose();
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
              member.user.tel,
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
              member.user.eMail,
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
          AutoSizeText(
            '비밀번호',
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
              member.user.password,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'NotoSansKR',
                color: Colors.black,
              ),
              minFontSize: 10,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 5),
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
        menuName: "내 정보",
      ),
      drawer: NkDrawer(
        id: id,
        password: password,
        member: member,
        storage: storage,
      ),
      body: Container(
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
          ],
        ),
      ),
    );
  }
}
