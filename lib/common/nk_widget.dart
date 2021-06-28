import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nkproject/home.dart';
import 'package:nkproject/login.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/pages/meeting.dart';
import 'package:nkproject/pages/my_page.dart';

class NkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final String menuName;

  NkAppBar({Key? key, required this.globalKey, required this.menuName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new AppBar(
      actions: [],
      backgroundColor: Colors.transparent,
      bottomOpacity: 0.0,
      elevation: 0.0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => globalKey.currentState!.openDrawer(),
      ),
      title: Container(
        height: 70,
        child: TextButton(
          onPressed: () {
            // Navigator.pushReplacement(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => HomePage(
            //       id: id,
            //       pass: pass,
            //       member: member,
            //     ),
            //   ),
            // );
          },
          child: Text(
            menuName,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'NotoSansKR',
            ),
          ),
        ),
      ),
      toolbarHeight: 100,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}

class NkDrawer extends StatelessWidget implements PreferredSizeWidget {
  final String id;
  final String password;
  final UserManager member;
  final FlutterSecureStorage storage;
  NkDrawer(
      {Key? key,
      required this.id,
      required this.password,
      required this.member,
      required this.storage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;

    Widget menuRow(String sMenuName) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Text(
              sMenuName,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSansKR',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 26,
            ),
          ),
        ],
      );
    }

    return new Drawer(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            height: 100,
            color: Color.fromRGBO(244, 242, 255, 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('resource/nk_logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        member.user.name + " 님",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: Text(
                        "안녕하세요.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'NotoSansKR',
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        storage.deleteAll();
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Login(
                              hpToken: member.user.hpToken,
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Entypo.log_out,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: screenHeight - 210,
            padding: EdgeInsets.all(45),
            child: ListView(
              children: [
                InkWell(
                  onTap: () {
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
                  child: menuRow('HOME'),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
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
                  child: menuRow('일정관리'),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
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
                  child: menuRow('회의관리'),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MyPage(
                          id: id,
                          password: password,
                          member: member,
                        ),
                      ),
                    );
                  },
                  child: menuRow('My Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
