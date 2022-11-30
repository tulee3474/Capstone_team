import 'dart:core';
import 'dart:math';

import 'package:danim/calendar_view.dart';
import 'package:danim/src/event_CalendarEventData_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:danim/components/image_data.dart';
import 'package:danim/model/event.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import '../app_colors.dart';
import '../constants.dart';
import '../extension.dart';
import 'package:danim/src/place.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:danim/src/start_end_day.dart';
import 'package:danim/src/preset.dart';
import '../../map.dart' as map;

import '../map.dart';
import '../route_ai.dart';
import '../tourinfo.dart';
import '../widgets/custom_button.dart';
import '../widgets/date_time_selector.dart';
import 'courseSelected.dart';
import 'createMovingTimeList.dart';
import 'date_selectlist.dart';
import 'foodRecommend.dart';
import 'package:danim/route.dart';
import 'package:danim/nearby.dart';
import 'package:danim/firebase_read_write.dart';
import 'package:danim/src/login.dart';
import 'package:danim/src/user.dart';

List<CalendarEventData<Event>> createEventList(List<List<Place>> preset,
    DateTime startDay, DateTime endDay, List<List<int>> moving_time) {
  int startDayTime = dayStartingTime.hour;
  int endDayTime = dayEndingTime.hour;

  bool lunch = false;
  bool dinner = false;

  //int timeIndex = startDayTime;
  DateTime timeIndex = DateTime(startDay.year, startDay.month, startDay.day,
      startDayTime, 0); //처음 타임인덱스 값
  int minuteIndex = 0;
  DateTime dayIndex = startDay;
  //int moving_time = 0;

  List<CalendarEventData<Event>> events = [];

  List<List<int>> drivingTimeList = [
    for (int i = 0; i < preset.length; i++) []
  ];

  List<List<TransitTime>> transitTimeList = [
    for (int i = 0; i < preset.length; i++) []
  ];

  for (int i = 0; i < preset.length; i++) {
    for (int j = 0; j < preset[i].length; j++) {
      if (timeIndex.compareTo(DateTime(
                  dayIndex.year, dayIndex.month, dayIndex.day, 11, 0)) >=
              0 &&
          timeIndex.compareTo(DateTime(
                  dayIndex.year, dayIndex.month, dayIndex.day, 14, 0)) <
              0 &&
          !lunch) {
        lunch = true;

        DateTime mealEndTime = DateTime(dayIndex.year, dayIndex.month,
                dayIndex.day, timeIndex.hour, timeIndex.minute)
            .add(Duration(hours: 1));

        events.add(CalendarEventData(
            title: '식사시간',
            date: dayIndex,
            event: Event(title: '식사시간'),
            description: '',
            latitude: 0,
            longitude: 0,
            startTime: DateTime(
              dayIndex.year,
              dayIndex.month,
              dayIndex.day,
              timeIndex.hour,
              timeIndex.minute,
            ),
            endTime: mealEndTime,
            color: Colors.orangeAccent));

        timeIndex = mealEndTime;

        DateTime transitEndTime = DateTime(dayIndex.year, dayIndex.month,
            dayIndex.day, timeIndex.hour, timeIndex.minute + 30);
        DateTime transitEndTimeUpdated = transitEndTime;

        events.add(CalendarEventData(
            title: '이동',
            date: dayIndex,
            event: Event(title: '이동'),
            description: '',
            latitude: 0,
            longitude: 0,
            startTime: DateTime(dayIndex.year, dayIndex.month, dayIndex.day,
                timeIndex.hour, timeIndex.minute),
            endTime: transitEndTime,
            color: Colors.grey));

        timeIndex = transitEndTime;
      }

      if (timeIndex.compareTo(DateTime(
                  dayIndex.year, dayIndex.month, dayIndex.day, 17, 0)) >=
              0 &&
          timeIndex.compareTo(DateTime(
                  dayIndex.year, dayIndex.month, dayIndex.day, 22, 0)) <
              0 &&
          !dinner) {
        dinner = true;

        DateTime mealEndTime = DateTime(dayIndex.year, dayIndex.month,
                dayIndex.day, timeIndex.hour, timeIndex.minute)
            .add(Duration(hours: 1));

        events.add(CalendarEventData(
            title: '식사시간',
            date: dayIndex,
            event: Event(title: '식사시간'),
            description: '',
            latitude: 0,
            longitude: 0,
            startTime: DateTime(
              dayIndex.year,
              dayIndex.month,
              dayIndex.day,
              timeIndex.hour,
              timeIndex.minute,
            ),
            endTime: mealEndTime,
            color: Colors.orangeAccent));

        timeIndex = mealEndTime;

        DateTime transitEndTime = DateTime(dayIndex.year, dayIndex.month,
            dayIndex.day, timeIndex.hour, timeIndex.minute + 30);
        DateTime transitEndTimeUpdated = transitEndTime;

        events.add(CalendarEventData(
            title: '이동',
            date: dayIndex,
            event: Event(title: '이동'),
            description: '',
            latitude: 0,
            longitude: 0,
            startTime: DateTime(dayIndex.year, dayIndex.month, dayIndex.day,
                timeIndex.hour, timeIndex.minute),
            endTime: transitEndTime,
            color: Colors.grey));

        timeIndex = transitEndTime;
      }

      if (timeIndex.compareTo(DateTime(
              dayIndex.year, dayIndex.month, dayIndex.day, endDayTime)) >
          0) {
        break;
      }

      DateTime tourEndTime = DateTime(
          dayIndex.year,
          dayIndex.month,
          dayIndex.day,
          timeIndex.hour,
          timeIndex.minute + preset[i][j].takenTime);
      DateTime tourEndTimeUpdated = tourEndTime;

      events
        ..add(CalendarEventData(
            title: '${preset[i][j].name}',
            date: dayIndex,
            event: Event(title: '${preset[i][j].name}'),
            description: '',
            latitude: preset[i][j].latitude,
            longitude: preset[i][j].longitude,
            startTime: DateTime(dayIndex.year, dayIndex.month, dayIndex.day,
                timeIndex.hour, timeIndex.minute),
            endTime: tourEndTimeUpdated));

      timeIndex = tourEndTimeUpdated;

      if (timeIndex.compareTo(DateTime(dayIndex.year, dayIndex.month,
              dayIndex.day, timeIndex.hour, timeIndex.minute)) >
          0) {
        break;
      }

      if (j < preset[i].length - 1) {
        DateTime transitEndTime = DateTime(dayIndex.year, dayIndex.month,
            dayIndex.day, timeIndex.hour, timeIndex.minute + moving_time[i][j]);
        DateTime transitEndTimeUpdated = transitEndTime;

        events.add(CalendarEventData(
            title: '이동',
            date: dayIndex,
            event: Event(title: '이동'),
            description: '',
            latitude: 0,
            longitude: 0,
            startTime: DateTime(dayIndex.year, dayIndex.month, dayIndex.day,
                timeIndex.hour, timeIndex.minute),
            endTime: transitEndTimeUpdated,
            color: Colors.grey));

        timeIndex = transitEndTimeUpdated;
      }
    }

    dayIndex = dayIndex.add(Duration(days: 1));
    timeIndex =
        DateTime(dayIndex.year, dayIndex.month, dayIndex.day, startDayTime, 0);

    lunch = false;
    dinner = false;
  }

  return events;
}

class Timetable extends StatefulWidget {
  Timetable(
      {Key? key,
      required this.preset,
      required this.transit,
      required this.movingTimeList})
      : super(key: key);

  int transit = 0; // 자차:0, 대중교통:1

  List<List<Place>> preset = [];
  DateTime currentDate = startDay;
  List<List<int>> movingTimeList;

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  final _CourseNameController = TextEditingController();

  late List<CalendarEventData<Event>> events =
      createEventList(widget.preset, startDay, endDay, widget.movingTimeList);

  String isSaved = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _CourseNameController.dispose();
    super.dispose();
  }

  int getTransit() {
    return widget.transit;
  }

  List<List<Place>> getPreset() {
    return widget.preset;
  }

  List<CalendarEventData<Event>> getEvents() {
    return events;
  }

  List<List<int>> getMovingTimeList() {
    return widget.movingTimeList;
  }

  void deletePlace(Place place) {
    setState(() {
      widget.preset.remove(place);
    });
  }

  void setEventList() {
    events =
        createEventList(widget.preset, startDay, endDay, widget.movingTimeList)
            as List<CalendarEventData<Event>>;
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Event>(
        controller: EventController<Event>()..addAll(events),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      //첫화면까지 팝해버리는거임
                    },
                    child: Image.asset(IconsPath.house,
                        fit: BoxFit.contain, height: 20)),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: SizedBox(
                                  height: 200,
                                  width: 300,
                                  child: Column(children: [
                                    Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 30, 0, 0),
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              //List<CalendarEventData<Event>> 에서 List<CalendarEventData> 로 변환 !!
                                              List<CalendarEventData>
                                                  eventsForDB = [];
                                              eventsForDB =
                                                  eventsToCalendarEventData(
                                                      events);

                                              //여기서 DB 연결 !!!
                                              // 현재 events 저장
                                              //print('$eventsForDB');


                                              for(int i=0; i<events.length;i++){
                                                print('저장하기 전 이벤트 위도 경도 출력 ${i} : ${events[i].latitude} , ${events[i].longitude}');
                                              }

                                              for(int i=0; i<eventsForDB.length;i++){
                                                print('저장하기 전 db이벤트 위도 경도 출력 ${i} : ${eventsForDB[i].latitude} , ${eventsForDB[i].longitude}');
                                              }

                                              //임시 토큰!
                                              if (token == '') {
                                                //int 최대치는 약 21억
                                                token = (Random().nextInt(
                                                            2100000000) +
                                                        1)
                                                    .toString();
                                              }
                                              print(token);
                                              print(token as String);

                                              ReadController read =
                                                  ReadController();
                                              User userData;
                                              try {
                                                userData = await read
                                                    .fb_read_user(token);
                                              } catch (e) {
                                                print(token);
                                                print(token as String);
                                                userData = User(
                                                  token as String,
                                                  token as String,
                                                  [],
                                                  [],
                                                  [],
                                                  [],
                                                  [],
                                                  [],
                                                );
                                              }
                                              print(userData.docCode);

                                              userData.travelList
                                                  .add("제주도"); //임시 city 고정
                                              //1일차, 2일차 수만큼 반복
                                              int placeSum = 0;
                                              List<String> placeLi = [];
                                              for (int p = 0;
                                                  p < getPreset().length;
                                                  p++) {
                                                placeSum +=
                                                    getPreset()[p].length;
                                                for (int q = 0;
                                                    q < getPreset()[p].length;
                                                    q++) {
                                                  placeLi.add(
                                                      getPreset()[p][q].name);
                                                }
                                              }
                                              userData.placeNumList
                                                  .add(placeSum);
                                              userData.traveledPlaceList =
                                                  List.from(userData
                                                      .traveledPlaceList)
                                                    ..addAll(placeLi);
                                              userData.eventNumList
                                                  .add(eventsForDB.length);
                                              userData.eventList =
                                                  List.from(userData.eventList)
                                                    ..addAll(eventsForDB);
                                              userData.diaryList.add("");
                                              fb_write_user(
                                                  userData.docCode,
                                                  userData.name,
                                                  userData.travelList,
                                                  userData.placeNumList,
                                                  userData.traveledPlaceList,
                                                  userData.eventNumList,
                                                  selectedList, //전역변수라서, 차후에 문제생길수도
                                                  userData.eventList,
                                                  userData.diaryList);

                                              print('pathlist saved');

                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                        content: SizedBox(
                                                            width: 150,
                                                            height: 50,
                                                            child: Container(
                                                                child: Text('Saved as : ' +
                                                                    userData
                                                                        .docCode
                                                                        .toString()))));
                                                  });
                                            },
                                            child: Text("코스 저장")))
                                  ])),
                            );
                          });
                    },
                    child: Icon(Icons.save))
              ]),
            ),
            floatingActionButton: Stack(children: [
              Align(
                  alignment: Alignment(
                      Alignment.bottomRight.x, Alignment.bottomRight.y - 0.15),
                  child: FloatingActionButton(
                    child: Icon(Icons.add),
                    elevation: 8,
                    onPressed: () async {
                      final event = await context
                          .pushRoute<CalendarEventData<Event>>(CreateEventPage(
                        getPreset: getPreset,
                        transit: widget.transit,
                        getEvents: getEvents,
                        currentDate: widget.currentDate,
                        getMovingTimeList: getMovingTimeList,
                        withDuration: true,
                      ));
                      if (event == null) return;
                      CalendarControllerProvider.of<Event>(context)
                          .controller
                          .add(event);
                    },
                  )),
            ]),
            body: DayViewWidget(
              transit: widget.transit,
              getPreset: getPreset,
              getEvents: getEvents,
              getMovingTimeList: getMovingTimeList,
            )));
  }
}

class DayViewWidget extends StatefulWidget {
  final GlobalKey<DayViewState>? state;
  final double? width;

  final Function() getPreset;
  final Function() getEvents;
  final Function() getMovingTimeList;

  int transit = 0;

  DayViewWidget({
    Key? key,
    this.state,
    this.width,
    required this.transit,
    required this.getPreset,
    required this.getEvents,
    required this.getMovingTimeList,
  }) : super(key: key);

  @override
  _DayViewWidgetState createState() => _DayViewWidgetState();
}

class _DayViewWidgetState extends State<DayViewWidget> {
  late List<CalendarEventData<Event>> events = widget.getEvents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DayView<Event>(
      minDay: startDay,
      maxDay: endDay,
      key: widget.state,
      width: widget.width,
      onEventTap: (event, date) async {
        if (event[0].title == '식사시간') {
          //여기에 다시 구현

          int mealIndex = 0;

          for (int i = 0; i < events.length; i++) {
            if (event[0].startTime.compareTo(events[i].startTime) == 0) {
              mealIndex = i;
            }
          }

          if ((mealIndex - 2) >= 0 && (mealIndex + 2) < events.length) {
            double lat1 = events[mealIndex - 2].latitude;
            double lon1 = events[mealIndex - 2].longitude;
            double lat2 = events[mealIndex + 2].latitude;
            double lon2 = events[mealIndex + 2].longitude;

            List<Restaurant> restList =
                await getRestaurant(lat1, lon1, lat2, lon2);
            for (int i = 0; i < restList.length; i++) {
              print('${restList[i].restName}\n');
            }
            map.addRestMarker(restList);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FoodRecommend()));
          }

          else{
            print("전후 관광지가 없습니다.");
          }

        } else if (event[0].title == '이동') {
        } else {
          String tourInformation = '';
          tourInformation = await getTourInfo(event[0].title);

          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                    content: SizedBox(
                        height: 350,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(children: [
                              Container(child: Text(tourInformation)),
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 240, 0, 0),
                                  child: ElevatedButton(
                                      child: Text("코스에서 삭제"),
                                      onPressed: () async {
                                        //pathlist에서 삭제해서 업데이트 해야함

                                        List<List<Place>> presetToBeUpdated =
                                            widget.getPreset();
                                        List<CalendarEventData<Event>>
                                            eventsToBeUpdated =
                                            widget.getEvents();
                                        List<List<Place>> presetUpdated = [
                                          for (int i = 0;
                                              i < presetToBeUpdated.length;
                                              i++)
                                            []
                                        ];

                                        int indexPreset = 0;
                                        int indexEvents = 0;
                                        int indexPath = 0;

                                        for (int i = 0;
                                            i < eventsToBeUpdated.length;
                                            i++) {
                                          if (eventsToBeUpdated[i].title ==
                                              event[0].title) {
                                            eventsToBeUpdated.removeAt(i);
                                          }
                                        }

                                        while (indexEvents <
                                                eventsToBeUpdated.length &&
                                            indexPreset <
                                                presetToBeUpdated.length) {
                                          print("while");
                                          if (eventsToBeUpdated[indexEvents]
                                                  .title ==
                                              '식사시간') {
                                            indexEvents++;
                                          } else if (eventsToBeUpdated[
                                                      indexEvents]
                                                  .title ==
                                              '이동') {
                                            indexEvents++;
                                          } else {
                                            if (eventsToBeUpdated[indexEvents]
                                                    .title !=
                                                presetToBeUpdated[indexPreset]
                                                        [indexPath]
                                                    .name) {
                                              indexPath++;

                                              if (indexPath >=
                                                  presetToBeUpdated[indexPreset]
                                                      .length) {
                                                indexPreset++;
                                                indexPath = 0;
                                              }
                                            } else {
                                              presetUpdated[indexPreset].add(
                                                  presetToBeUpdated[indexPreset]
                                                      [indexPath]);
                                              indexEvents++;
                                              indexPath++;

                                              print("여기까지옴");

                                              if (indexPath >=
                                                  presetToBeUpdated[indexPreset]
                                                      .length) {
                                                indexPreset++;
                                                indexPath = 0;
                                              }
                                            }
                                          }
                                        }

                                        List<List<int>> movingTimeList;

                                        if (widget.transit == 0) {
                                          movingTimeList =
                                              await createDrivingTimeList(
                                                  presetUpdated);
                                        } else {
                                          movingTimeList =
                                              await createTransitTimeList(
                                                  presetUpdated);
                                        }
                                        setState(() {
                                          course_selected = presetUpdated;
                                          //map.addMarker(presetUpdated[course_selected_day_index]);
                                          //map.addPoly(presetUpdated[course_selected_day_index]);
                                        });

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Timetable(
                                                      preset: presetUpdated,
                                                      movingTimeList:
                                                          movingTimeList,
                                                      transit: widget.transit,
                                                    )));

                                        print("pathlist updated");
                                        print(event);
                                      })),
                            ]))));
              });
        }
      },
      showLiveTimeLineInAllDays: false,
    ));
  }
}

class CreateEventPage extends StatefulWidget {
  final bool withDuration;
  final void Function(CalendarEventData<Event>)? onEventAdd;

  DateTime currentDate;

  final Function() getPreset;
  final Function() getEvents;
  final Function() getMovingTimeList;

  int transit = 0;

  CreateEventPage(
      {Key? key,
      this.withDuration = false,
      required this.getPreset,
      required this.transit,
      required this.getMovingTimeList,
      required this.getEvents,
      required this.currentDate,
      this.onEventAdd})
      : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  DateTime _startDate = startDay.add(Duration(days: course_selected_day_index));
  //late DateTime _endDate;

  String newPlaceName = '';
  double newPlaceLat = 0;
  double newPlaceLon = 0;

  late DateTime _startTime;

  late DateTime _endTime;

  String _title = "";

  double _latitude = 0;

  double _longitude = 0;

  String _description = "";

  Color _color = Colors.blue;

  String _titleNode = '';

  late FocusNode _descriptionNode;

  late FocusNode _dateNode;

  final GlobalKey<FormState> _form = GlobalKey();

  //late TextEditingController _startDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  //late TextEditingController _endDateController;

  /*
  void _createEvent() {
    if (!(_form.currentState?.validate() ?? true)) return;

    _form.currentState?.save();

    final event = CalendarEventData<Event>(
      date: widget.currentDate,
      color: _color,
      endTime: _endTime,
      startTime: _startTime,
      description: _description,
      endDate: widget.currentDate,
      title: _title,
      event: Event(
        title: _title,
      ),
    );

    widget.onEventAdd?.call(event);
    _resetForm();
  }*/

  /*

  void _resetForm() {
    _form.currentState?.reset();
    //_startDateController.text = "";
    _endTimeController.text = "";
    _startTimeController.text = "";
  }
*/

  void _displayColorPicker() {
    var color = _color;
    showDialog(
      context: context,
      useSafeArea: true,
      barrierColor: Colors.black26,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: AppColors.bluishGrey,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(20.0),
        children: [
          Text(
            "Event Color",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 25.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            height: 1.0,
            color: AppColors.bluishGrey,
          ),
          ColorPicker(
            displayThumbColor: true,
            enableAlpha: false,
            pickerColor: _color,
            onColorChanged: (c) {
              color = c;
            },
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
              child: CustomButton(
                title: "Select",
                onTap: () {
                  if (mounted)
                    setState(() {
                      _color = color;
                    });
                  context.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _descriptionNode = FocusNode();
    _dateNode = FocusNode();

    //_startDateController = TextEditingController();
    //_endDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionNode.dispose();
    _dateNode.dispose();

    //_startDateController.dispose();
    //_endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    super.dispose();
  }

  String location3 = "Search Location";
  @override
  Widget build(BuildContext context) {
    _TimetableState? parent =
        context.findAncestorStateOfType<_TimetableState>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
        // title: Text(
        //   "관광지 추가",
        //   style: TextStyle(
        //     color: AppColors.black,
        //     fontSize: 20.0,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                //첫화면까지 팝해버리는거임
              },
              child:
                  Image.asset(IconsPath.house, fit: BoxFit.contain, height: 20))
        ]),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                  onTap: () async {
                    var place = await PlacesAutocomplete.show(
                      context: context,
                      apiKey: 'AIzaSyD0em7tm03lJXoj4TK47TcunmqfjDwHGcI',
                      mode: Mode.overlay,
                      language: "kr",
                      //types: [],
                      //strictbounds: false,
                      components: [Component(Component.country, 'kr')],
                      //google_map_webservice package
                      //onError: (err){
                      //  print(err);
                      //},
                    );

                    if (place != null) {
                      setState(() {
                        location3 = place.description.toString();
                      });

                      //form google_maps_webservice package
                      final plist = GoogleMapsPlaces(
                        apiKey: 'AIzaSyD0em7tm03lJXoj4TK47TcunmqfjDwHGcI',
                        apiHeaders: await GoogleApiHeaders().getHeaders(),
                        //from google_api_headers package
                      );

                      String placeid = place.placeId ?? "0";
                      final detail = await plist.getDetailsByPlaceId(placeid);
                      final geometry = detail.result.geometry!;
                      final lat = geometry.location.lat;
                      final lang = geometry.location.lng;
                      var newlatlang = LatLng(lat, lang);
                      //latLen.add(newlatlang);

                      //move map camera to selected place with animation
                      //mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                      var places = location3.split(', ');
                      String placeName = places[places.length - 1];

                      //새로운 이벤트의 타이틀, 위도, 경도
                      _title = placeName;
                      _latitude = lat;
                      _longitude = lang;

                      //newPlace의 위도
                      newPlaceLat = lat;
                      newPlaceLon = lang;

                      print(_title);

                      placeList.add(Place(
                          placeName,
                          lat,
                          lang,
                          60,
                          20,
                          selectedList[0],
                          selectedList[1],
                          selectedList[2],
                          selectedList[3],
                          selectedList[4]));
                      setState(() {});
                      setState(() {});
                    } else {
                      setState(() {
                        location3 = "Search Location";
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Card(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListTile(
                            title: Text(
                              location3,
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Icon(Icons.search),
                            dense: true,
                          )),
                    ),
                  )),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(child: Text('날짜 : ' + '${_startDate}')),
                  SizedBox(width: 20.0),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: DateTimeSelectorFormField(
                      controller: _startTimeController,
                      decoration: AppConstants.inputDecoration.copyWith(
                        labelText: "시작 시간",
                      ),
                      validator: (value) {
                        if (value == null || value == "")
                          return "Please select start time.";

                        return null;
                      },
                      onSave: (date) => _startTime = date,
                      textStyle: TextStyle(
                        color: AppColors.black,
                        fontSize: 17.0,
                      ),
                      type: DateTimeSelectionType.time,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: DateTimeSelectorFormField(
                      controller: _endTimeController,
                      decoration: AppConstants.inputDecoration.copyWith(
                        labelText: "종료 시간",
                      ),
                      validator: (value) {
                        if (value == null || value == "")
                          return "Please select end time.";

                        return null;
                      },
                      onSave: (date) => _endTime = date,
                      textStyle: TextStyle(
                        color: AppColors.black,
                        fontSize: 17.0,
                      ),
                      type: DateTimeSelectionType.time,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              )

              /*
          TextFormField(
            focusNode: _descriptionNode,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 17.0,
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            selectionControls: MaterialTextSelectionControls(),
            minLines: 1,
            maxLines: 10,
            maxLength: 1000,
            validator: (value) {
              if (value == null || value.trim() == "")
                return "Please enter event description.";

              return null;
            },
            onSaved: (value) => _description = value?.trim() ?? "",
            decoration: AppConstants.inputDecoration.copyWith(
              hintText: "Event Description",
            ),
          )
          */
              ,
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Text(
                    "색상: ",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 17,
                    ),
                  ),
                  GestureDetector(
                    onTap: _displayColorPicker,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: _color,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              CustomButton(
                onTap: () async {
                  _form.currentState?.save();

                  final newEvent = CalendarEventData<Event>(
                    date: _startDate,
                    color: _color,
                    endTime: _endTime,
                    startTime: _startTime,
                    description: _description,
                    title: _title,
                    latitude: _latitude,
                    longitude: _longitude,
                    event: Event(
                      title: _title,
                    ),
                  );

                  print('${newEvent.date}');
                  print(newEvent.title);
                  print("${newEvent.startTime}");
                  print("${newEvent.endTime}");

                  //newEvent 생성까지 완료.

                  List<List<Place>> presetToBeUpdated = widget.getPreset();
                  print(presetToBeUpdated);
                  //원래 코스 로드 완료

                  List<CalendarEventData<Event>> eventsToBeUpdated =
                      widget.getEvents();
                  print(eventsToBeUpdated);
                  //원래 이벤트리스트 로드 완료

                  CalendarEventData<Event> eventBefore = CalendarEventData(
                      title: 'dummy',
                      date: DateTime.now(),
                      latitude: 0,
                      longitude: 0,
                      startTime: DateTime.now(),
                      endTime: DateTime.now().add(Duration(hours: 1)));
                  CalendarEventData<Event> eventAfter = CalendarEventData(
                      title: 'dummy',
                      latitude: 0,
                      longitude: 0,
                      date: DateTime.now(),
                      startTime: DateTime.now(),
                      endTime: DateTime.now().add(Duration(hours: 1)));

                  Place newPlace = Place(
                      '${newEvent.title}',
                      newPlaceLat,
                      newPlaceLon,
                      _endTime.difference(_startTime).inMinutes,
                      30,
                      [10, 20, 30, 40, 50, 60, 70],
                      [10, 20, 30, 40, 50],
                      [10, 20, 30, 40, 50, 60],
                      [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110],
                      [10, 20, 30, 40]);

                  print(newPlace);
                  //newPlace 생성 완료

                  /*
                  for(int i=0; i< eventsToBeUpdated.length; i++){

                    if(newEvent.date.year == eventsToBeUpdated[i].date.year && newEvent.date.month == eventsToBeUpdated[i].date.month && newEvent.date.day == eventsToBeUpdated[i].date.day ){

                      if(newEvent.startTime.hour > eventsToBeUpdated[i].startTime.hour && newEvent.startTime.hour < eventsToBeUpdated[i+1].startTime.hour){

                        eventBefore = eventsToBeUpdated[i];
                        eventAfter = eventsToBeUpdated[i+1];

                        print(eventBefore);
                        print(eventAfter);

                      }

                    }

                  }

                   */

                  //eventBefore 찾기

                  for (int i = 0; i < eventsToBeUpdated.length; i++) {
                    if (newEvent.date.year == eventsToBeUpdated[i].date.year &&
                        newEvent.date.month ==
                            eventsToBeUpdated[i].date.month &&
                        newEvent.date.day == eventsToBeUpdated[i].date.day) {
                      if (eventsToBeUpdated[i].title != '식사시간' &&
                          eventsToBeUpdated[i].title != '이동') {
                        if (eventsToBeUpdated[i].startTime.hour <
                            newEvent.startTime.hour) {
                          eventBefore = eventsToBeUpdated[i];
                          print(eventBefore.title);
                          //eventBefore 찾기 완료
                        }
                      }
                    }
                  }

                  if(presetToBeUpdated[course_selected_day_index].length == 0){
                    presetToBeUpdated[course_selected_day_index].add(newPlace);
                    print("path created");
                    print(presetToBeUpdated);

                  }
                  else{
                  for (int i = 0; i < presetToBeUpdated.length; i++) {
                    for (int j = 0; j < presetToBeUpdated[i].length; j++) {
                      if (presetToBeUpdated[i][j].name == eventBefore.title) {
                        presetToBeUpdated[i].insert(j + 1, newPlace);

                        print("path updated");
                        print(presetToBeUpdated);
                      }
                    }
                  }}

                  List<List<int>> movingTimeList = [];

                  if (widget.transit == 0) {
                    movingTimeList =
                        (await createDrivingTimeList(presetToBeUpdated));
                  } else {
                    movingTimeList =
                        (await createTransitTimeList(presetToBeUpdated));
                  }

                  //print(movingTimeList);

                  if (movingTimeList.isEmpty) {
                    print('movimgTimeList is empty');
                  }
                  setState(() {
                    course_selected = presetToBeUpdated;
                    //map.addMarker(presetToBeUpdated[course_selected_day_index]);
                    //map.addPoly(presetToBeUpdated[course_selected_day_index]);
                  });
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Timetable(
                                preset: presetToBeUpdated,
                                movingTimeList: movingTimeList,
                                transit: widget.transit,
                              )));
                },
                title: "관광지 추가",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
