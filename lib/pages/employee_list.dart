import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nkproject/common/api_service.dart';
import 'package:nkproject/model/employee_model.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/pages/meeting_write.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EmployeeList extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  EmployeeList({
    required this.id,
    required this.password,
    required this.member,
  });
  @override
  EmployeeListState createState() => new EmployeeListState();
}

class EmployeeListState extends State<EmployeeList> {
  MeetingWriteState meetingWrite = MeetingWriteState();

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

  @override
  void initState() {
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
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

  employeeCard(String sDepartName, String sPosition, String sName,
      String sDepartNameTwo, String sUserId) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 35,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: employeeRowText(sDepartName, TextAlign.left),
          ),
          Expanded(
            flex: 1,
            child: employeeRowText(sPosition, TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: employeeRowText(sName, TextAlign.center),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                setState(() {});
                Navigator.of(context).pop();
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
                ListTile(
                  title: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    color: Colors.cyan[700],
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: memberPopupHead("부서"),
                        ),
                        Expanded(
                          flex: 1,
                          child: memberPopupHead("직급"),
                        ),
                        Expanded(
                          flex: 2,
                          child: memberPopupHead("성명"),
                        ),
                        Expanded(
                          flex: 1,
                          child: memberPopupHead("선택"),
                        ),
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
                                employeeListValue.elementAt(i).userId),
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
