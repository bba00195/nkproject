// #region Import
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/model/login_model.dart';
// #endregion

class Login extends StatefulWidget {
  final String hpToken;

  Login({
    required this.hpToken,
  });
  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {
  late String hpToken = '';
  static final storage = new FlutterSecureStorage();

  bool hidePassword = true; // Password Hide

  final idTextEditController = TextEditingController();
  final passwordTextEditController = TextEditingController();

  GlobalKey<FormState> idFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  FocusNode idFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  var member = UserManager();
  String sRsMsg = '';

  @override
  void initState() {
    super.initState();
    hpToken = widget.hpToken;
  }

  @override
  void dispose() {
    idTextEditController.dispose();
    passwordTextEditController.dispose();
    super.dispose();
  }

  login(String sUserId, String sPassword) async {
    if (sUserId == '') {
      show("아이디를 입력해주세요."); // 아이디 미입력
      return;
    }
    if (sPassword == '') {
      show("비밀번호를 입력해주세요."); // 비밀번호 미입력
      return;
    }
    List<String> sParam = [sUserId];

    APIService apiService = new APIService();
    await apiService.getSelect("LOGIN_S1", sParam).then((value) {
      setState(() {
        if (value.login.isNotEmpty) {
          if (passwordTextEditController.text !=
              value.login.elementAt(0).password) {
            show("비밀번호가 일치하지 않습니다."); // 비밀번호 불일치
          } else {
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
              hpToken: '',
            );
            storage.write(
              key: "login",
              value: "id " +
                  idTextEditController.text.toString() +
                  " " +
                  "password " +
                  passwordTextEditController.text.toString(),
            );
            sRsMsg = 'S';
          }
        } else {
          show("등록되지 않는 아이디입니다."); // 등록되지 않은 아이디
          sRsMsg = 'E';
        }
      });
    });
  }

  tokenUpdate(String sUserId, String sHpToken) async {
    List<String> sParam = [sUserId, sHpToken];

    APIService apiService = new APIService();
    await apiService.getUpdate("LOGIN_U1", sParam).then((value) {
      if (value.result.isNotEmpty) {
        member.user.hpToken = sHpToken;
      } else {
        show("토큰 등록에 실패하였습니다.");
      }
    });
  }

  // #region Logo
  logo() {
    return Container(
      alignment: Alignment.bottomLeft,
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage('resource/nk_logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
    // CircleAvatar(
    //   backgroundColor: Colors.transparent,
    //   radius: 48.0,
    //   child: Image.asset('resource/nk_logo.png'),
    // );
  }
  // #endregion

  // #region IdTextField
  txtUserId() {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      child: Form(
        key: idFormKey,
        child: TextField(
          autofocus: false,
          controller: idTextEditController,
          focusNode: idFocusNode,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.grey[400],
              ), // clear text
              onPressed: () {
                idTextEditController.clear();
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
            hintText: '아이디를 입력해주세요.',
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),
    );
  }
  // #endregion

  // #region PasswordTextField
  txtPassword() {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      child: Form(
        key: passwordFormKey,
        child: TextField(
          autofocus: false,
          controller: passwordTextEditController,
          focusNode: passwordFocusNode,
          decoration: InputDecoration(
            suffixIcon: Container(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    color: Theme.of(context).accentColor.withOpacity(0.4),
                    icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey[400],
                    ), // clear text
                    onPressed: () {
                      passwordTextEditController.clear();
                    },
                  ),
                ],
              ),
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
            hintText: '비밀번호를 입력해주세요.',
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoSansKR',
          ),
          obscureText: hidePassword,
        ),
      ),
    );
  }
  // #endregion

  // #region IdPanel
  pnlUserName() {
    return Container(
      height: 65,
      child: Stack(
        alignment: AlignmentDirectional.center, //alignment:new Alignment(x, y)
        children: <Widget>[
          txtUserId(),
          // userIcon,
        ],
      ),
    );
  }
  // #endregion

  // #region PasswordPanel
  pnlPassword() {
    return Container(
      height: 65,
      child: Stack(
        alignment: AlignmentDirectional.center, //alignment:new Alignment(x, y)
        children: <Widget>[
          txtPassword(),
          // lockIcon,
        ],
      ),
    );
  }
  // #endregion

  // #region ButtonLogin
  loginButton() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      // padding: EdgeInsets.only(left: 35.0, right: 35.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // shape: new RoundedRectangleBorder(
          //   borderRadius: new BorderRadius.circular(5),
          // ),
          primary: Color.fromRGBO(66, 91, 168, 1.0),
        ),
        onPressed: () async {
          await login(
              idTextEditController.text, passwordTextEditController.text);
          print('1');
          if (sRsMsg == "S") {
            await tokenUpdate(idTextEditController.text, hpToken);
            print('2');
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Home(
                    id: idTextEditController.text,
                    password: passwordTextEditController.text,
                    member: member),
              ),
            );
          }
        },
        child: Text(
          '로그인',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  // #endregion
  //
  // #endregion

  // #endregion

  @override
  Widget build(BuildContext context) {
    // #region Widget

    // #region Body
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      body: GestureDetector(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              logo(),
              SizedBox(height: 10),
              pnlUserName(),
              SizedBox(height: 5),
              pnlPassword(),
              SizedBox(height: 30),
              loginButton(),
              // hiddenLogin
            ],
          ),
        ),
        onTap: () {
          focusChange(context, idFocusNode);
          focusChange(context, passwordFocusNode);
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

  // #endregion

  void focusChange(BuildContext context, FocusNode currentFocus) {
    currentFocus.unfocus(); //현재 FocusNode의 포커스를 지운다.
  }
}
