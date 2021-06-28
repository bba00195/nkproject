import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:nkproject/common/nk_widget.dart';
import 'package:nkproject/model/login_model.dart';
import 'package:nkproject/model/schedule_model.dart';
import 'package:nkproject/pages/board_write.dart';
import 'package:nkproject/pages/schedule_detail.dart';
import 'package:nkproject/pages/schedule_write.dart';
import 'package:nkproject/utils.dart';
import 'package:table_calendar/table_calendar.dart';

import 'common/api_service.dart';

class Home extends StatefulWidget {
  final String id;
  final String password;
  final UserManager member;

  Home({
    required this.id,
    required this.password,
    required this.member,
  });

  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  static final storage = FlutterSecureStorage();
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  late String id;
  late String password;
  late UserManager member;
  APIService apiService = new APIService();

  late final PageController _pageController;
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final ValueNotifier<DateTime> headDay = ValueNotifier(DateTime.now());

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<ScheduleListResponseModel> scheduleValue = [];

  List<String> scheduleStarts = [];
  List<List<Event>> scheduleEventList = [];

  Map<DateTime, List<Event>> _events = {};

  late String date;

  late DateTime dateNow;
  int sDay = 0;

  @override
  void initState() {
    super.initState();
    id = widget.id; //widget.id는 LogOutPage에서 전달받은 id를 의미한다.
    password = widget.password; //widget.pass LogOutPage에서 전달받은 pass 의미한다.
    member = widget.member;
    dateNow = DateTime.parse(
        DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' 00:00:00.000Z');
    asyncMethod();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void asyncMethod() async {
    await scheduleSearch();
    print('456');
  }

  scheduleSearch() async {
    List<String> sParam = [
      member.user.userId,
      DateFormat('yyyy').format(dateNow),
      DateFormat('MM').format(dateNow),
      '',
    ];
    await apiService.getSelect("SCHEDULE_LIST_APP_S1", sParam).then((value) {
      setState(() {
        if (value.schedule.isNotEmpty) {
          scheduleValue = value.schedule;
          List<Event> scheduleEvent = [];
          for (int i = 0; i < scheduleValue.length; i++) {
            if (i == (scheduleValue.length) - 1) {
              scheduleStarts.add(scheduleValue.elementAt(i).starts);
              scheduleEvent
                  .add(Event(scheduleValue.elementAt(i).appoId.toString()));
              scheduleEventList.add(scheduleEvent);
              scheduleEvent = [];
            } else {
              if (scheduleValue.elementAt(i).starts ==
                  scheduleValue.elementAt(i + 1).starts) {
                scheduleEvent
                    .add(Event(scheduleValue.elementAt(i).appoId.toString()));
              } else {
                scheduleStarts.add(scheduleValue.elementAt(i).starts);
                scheduleEvent
                    .add(Event(scheduleValue.elementAt(i).appoId.toString()));
                scheduleEventList.add(scheduleEvent);
                scheduleEvent = [];
              }
            }
          }
          for (int i = 0; i < scheduleStarts.length; i++) {
            _events.putIfAbsent(
                DateTime.parse((scheduleStarts[i] + ' 00:00:00.000Z')),
                () => scheduleEventList[i]);
          }
        } else {}
        _onDaySelected(dateNow, dateNow);
      });
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return _events[day] ?? [];
  }

  List<String> schSubject = [];
  List<int> schAppoState = [];
  List<String> schUserId = [];
  List<String> schName = [];

  _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      schSubject = [];
      schAppoState = [];
      schUserId = [];
      schName = [];
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _selectedEvents.value = _getEventsForDay(selectedDay);
    for (int i = 0; i < _selectedEvents.value.length; i++) {
      for (int j = 0; j < scheduleValue.length; j++) {
        if (_selectedEvents.value[i].title ==
            scheduleValue.elementAt(j).appoId.toString()) {
          schSubject.add(scheduleValue.elementAt(j).subject);
          schAppoState.add(scheduleValue.elementAt(j).appoState);
          schUserId.add(scheduleValue.elementAt(j).regUserId);
          schName.add(scheduleValue.elementAt(j).regUserName);
        }
      }
    }
  }

  buildCalendarDay(String day) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
      ),
      width: 53,
      height: 53,
      child: Center(
        child: Text(day, style: TextStyle(fontSize: 14, color: Colors.black)),
      ),
    );
  }

  // addSchedule() {
  //   return Container(
  //     alignment: Alignment.centerRight,
  //     height: 40,
  //     margin: EdgeInsets.symmetric(horizontal: 15),
  //     width: MediaQuery.of(context).size.width,
  //     child: InkWell(
  //       onTap: () {
  //         // showMessage();
  //         Navigator.push(
  //           context,
  //           CupertinoPageRoute(
  //             builder: (context) => ScheduleWrite(),
  //           ),
  //         );
  //       },
  //       child: Icon(
  //         Icons.add_circle_outline_sharp,
  //         size: 30,
  //       ),
  //     ),
  //   );
  // }

  buildEventsMarkerNum(List events) {
    return buildCalendarDayMarker('${events.length}', Colors.blue);
  }

  buildCalendarDayMarker(String text, Color backColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: backColor,
      ),
      width: 51,
      height: 13,
      child: Center(
        child: Text(
          text,
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  boxScheculeCalendar() {
    return TableCalendar<Event>(
      headerVisible: false,
      // headerStyle: HeaderStyle(
      //   // headerMargin:
      //   //     EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
      //   titleCentered: true,
      //   formatButtonVisible: false,
      //   leftChevronIcon: Icon(Icons.arrow_left),
      //   rightChevronIcon: Icon(Icons.arrow_right),
      //   titleTextStyle: const TextStyle(fontSize: 17.0),
      // ),
      locale: 'ko-KR',
      firstDay: DateTime.utc(1950, 01, 01),
      lastDay: DateTime.utc(2050, 01, 01),
      focusedDay: headDay.value,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, _events) {
          final children = <Widget>[];
          if (_events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: 1,
                child: buildEventsMarkerNum(_events),
              ),
            );
          }
          for (int i = 0; i < children.length; i++) return children[i];
        },
        selectedBuilder: (context, date, _) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(22),
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Text(date.day.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          );
        },
      ),
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableCalendarFormats: const {
        CalendarFormat.month: '월간',
        // CalendarFormat.week: '주간',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
        weekendTextStyle: TextStyle().copyWith(color: Colors.red),
      ),
      onCalendarCreated: (controller) => _pageController = controller,
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        headDay.value = focusedDay;
        _focusedDay = focusedDay;
      },
    );
  }

  boxScheduleAdd() {
    return Container(
      alignment: Alignment.center,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Container(
        height: 60,
        margin: const EdgeInsetsDirectional.only(start: 1, end: 1, top: 1),
        padding: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(250, 250, 250, 1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(40),
            topRight: const Radius.circular(40),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: AutoSizeText(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'NotoSansKR',
                  color: Colors.black,
                ),
                maxLines: 1,
                minFontSize: 16,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () {
                    // showMessage();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ScheduleWrite(
                          id: id,
                          password: password,
                          member: member,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add_circle_outline_sharp,
                    size: 30,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  boxScheduleList() {
    return Container(
      child: ValueListenableBuilder<List<Event>>(
        valueListenable: _selectedEvents,
        builder: (context, value, _) {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 60,
                        ),
                        child: Center(
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: (schAppoState[index] == 0)
                                  ? Color.fromRGBO(255, 165, 0, 1)
                                  : (schAppoState[index] == 1)
                                      ? Color.fromRGBO(142, 195, 31, 1)
                                      : (schAppoState[index] == 2)
                                          ? Color.fromRGBO(66, 91, 168, 1)
                                          : Color.fromRGBO(230, 58, 84, 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: InkWell(
                        onTap: () {
                          print(value[index]);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ScheduleDetail(
                                id: id,
                                password: password,
                                member: member,
                                appoId: int.parse(value[index].toString()),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 60,
                          ),
                          margin: EdgeInsets.symmetric(
                            // horizontal: 20,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: (schAppoState[index] == 0)
                                  ? Color.fromRGBO(255, 165, 0, 0.5)
                                  : (schAppoState[index] == 1)
                                      ? Color.fromRGBO(142, 195, 31, 0.5)
                                      : (schAppoState[index] == 2)
                                          ? Color.fromRGBO(66, 91, 168, 0.5)
                                          : Color.fromRGBO(230, 58, 84, 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5.0,
                                offset: const Offset(0.0, 0.0),
                                color: (schAppoState[index] == 0)
                                    ? Color.fromRGBO(255, 165, 0, 0.5)
                                    : (schAppoState[index] == 1)
                                        ? Color.fromRGBO(142, 195, 31, 0.5)
                                        : (schAppoState[index] == 2)
                                            ? Color.fromRGBO(66, 91, 168, 0.5)
                                            : Color.fromRGBO(230, 58, 84, 0.5),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  child: AutoSizeText(
                                    "${schName[index]}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'NotoSansKR',
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    // .all(color: Colors.green),
                                  ),
                                  child: AutoSizeText(
                                    "${schSubject[index]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'NotoSansKR',
                                    ),
                                    minFontSize: 10,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(),
                              ),
                            ],
                          ),
                          // ListTile(
                          //   onTap: () => print('${value[index]}'),
                          //   title: Text('${schSubject[index]}'),
                          // ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: NkAppBar(
        globalKey: scaffoldKey,
        menuName: "Main",
      ),
      drawer: NkDrawer(
        id: id,
        password: password,
        member: member,
        storage: storage,
      ),
      body: Column(
        children: [
          // addSchedule(),
          ValueListenableBuilder<DateTime>(
            valueListenable: headDay,
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                onLeftArrowTap: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() {
                    sDay -= 30;
                    dateNow = DateTime.parse(DateFormat('yyyy-MM-dd')
                            .format(DateTime.now().add(Duration(days: sDay))) +
                        ' 00:00:00.000Z');
                    scheduleSearch();
                    _onDaySelected(dateNow, dateNow);
                  });
                },
                onRightArrowTap: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() {
                    sDay += 30;
                    dateNow = DateTime.parse(DateFormat('yyyy-MM-dd')
                            .format(DateTime.now().add(Duration(days: sDay))) +
                        ' 00:00:00.000Z');
                    scheduleSearch();
                    _onDaySelected(dateNow, dateNow);
                  });
                },
              );
            },
          ),
          boxScheculeCalendar(),
          SizedBox(height: 20),
          boxScheduleAdd(),
          SizedBox(height: 10),
          Expanded(
            child: boxScheduleList(),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM('ko-KR').format(focusedDay);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: onLeftArrowTap,
            ),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              width: 120.0,
              child: Text(
                headerText,
                style: TextStyle(fontSize: 26.0),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: onRightArrowTap,
            ),
          ),
        ],
      ),
    );
  }
}
