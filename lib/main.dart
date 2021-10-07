import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/login.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

String _token = '';
void main() async {
  initializeDateFormatting().then((_) => runApp(MyApp()));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken().then(print);
  FirebaseMessaging.instance.getToken().then((token) {
    _token = token.toString();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String userInfo = "";
  static final storage =
      new FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업
  late Timer timer;
  double percent = 0.0;

  _asyncMethod() async {
    await new Future.delayed(const Duration(milliseconds: 2000));

    userInfo = await storage.read(key: "login");

    //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    if (userInfo != null) {
      var member = UserManager();

      List<String> sParam = [userInfo.split(" ")[1]];

      APIService apiService = new APIService();
      apiService.getSelect("LOGIN_S1", sParam).then((value) {
        if (value.login.isNotEmpty) {
          member.user = User(
            uniqueId: value.login.elementAt(0).uniqueId,
            userId: value.login.elementAt(0).userId,
            passwd: value.login.elementAt(0).passwd,
            password: value.login.elementAt(0).password,
            authorId: value.login.elementAt(0).authorId,
            dupInfo: value.login.elementAt(0).dupInfo,
            employeeCode: value.login.elementAt(0).employeeCode,
            name: value.login.elementAt(0).name,
            position: value.login.elementAt(0).position,
            eMail: value.login.elementAt(0).eMail,
            tel: value.login.elementAt(0).tel,
            sex: value.login.elementAt(0).sex,
            departCode: value.login.elementAt(0).departCode,
            departFullName: value.login.elementAt(0).departFullName,
            departName: value.login.elementAt(0).departName,
            departHead: value.login.elementAt(0).departHead,
            hpToken: value.login.elementAt(0).hpToken,
          );
        } else {
          AlertDialog();
        }

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => Home(
              id: userInfo.split(" ")[1],
              password: userInfo.split(" ")[3],
              member: member,
            ),
          ),
        );
      });
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Login(
            hpToken: _token,
          ),
        ),
      );
    }
  }

  initState() {
    timer = Timer.periodic(Duration(milliseconds: 4000), (_) {
      setState(() {
        percent += 100;
        if (percent >= 100) {
          timer.cancel();
          percent = 100;
          _asyncMethod();
        }
      });
    });
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage('resource/nk_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.4,
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Green Promise',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                ),
                minFontSize: 20,
                maxLines: 1,
              ),
              SizedBox(height: 5),
              AutoSizeText(
                'for the people',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                ),
                minFontSize: 20,
                maxLines: 1,
              ),
              SizedBox(height: 15),
              AutoSizeText(
                '사람과 자연을 생각하는 기업,',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                minFontSize: 10,
                maxLines: 1,
              ),
              SizedBox(height: 5),
              AutoSizeText(
                '친환경 고효율 에너지 사업의 선두주자 NK',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                minFontSize: 10,
                maxLines: 1,
              ),
              SizedBox(height: 30),
              Container(
                alignment: Alignment.centerLeft,
                child: LinearPercentIndicator(
                  //leaner progress bar
                  animation: true,
                  animationDuration: 1000,
                  lineHeight: 5.0,
                  percent: percent / 100,
                  linearStrokeCap: LinearStrokeCap.butt,
                  progressColor: Colors.white,
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
                ),
              ),
              // Container(
              //   height: 5,
              //   width: MediaQuery.of(context).size.width,
              //   color: Color.fromRGBO(255, 255, 255, 0.3),
              //   child: Container(
              //     height: 5,
              //     width: MediaQuery.of(context).size.width * 0.1,
              //     color: Color.fromRGBO(255, 255, 255, 1),
              //   ),
              // ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
