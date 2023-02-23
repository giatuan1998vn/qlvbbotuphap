import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qlvbbotuphap/Login.dart';
import 'package:qlvbbotuphap/btnavigator_widget.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';
import 'package:qlvbbotuphap/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedStorage = await SharedPreferences.getInstance();
  if(sharedStorage.containsKey("expires_in")){
    var expireIn = sharedStorage.getString("expires_in");
    DateTime now = DateTime.now();
    var checkTimetoken = DateTime.parse(expireIn!).compareTo(now);
    if(checkTimetoken > 0){
      isLogin = true;
    }else{
      isLogin = false;
    }
  }else{
    isLogin = false;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Notification(),
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
              textScaleFactor: data.textScaleFactor > 2.0 ? 2.0 : data.textScaleFactor),
          child: FlutterEasyLoading(child: child),
        )  ;
      },
    );
  }
}

// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =  BehaviorSubject<ReceivedNotification>();
// final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
Future<dynamic>? myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
  }
  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
  }
}

class Notification extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  SharedPreferences? sharedStorage;
  final _keymain = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //pushNotification();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // final IOSInitializationSettings initializationSettingsIOS =
    // // IOSInitializationSettings(
    // //     requestSoundPermission: true,
    // //     requestBadgePermission: true,
    // //     requestAlertPermission: true,
    // //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    // var initSetttings = new InitializationSettings(
    //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // // flutterLocalNotificationsPlugin!.initialize(initSetttings,
    // //     onSelectNotification: onSelectNotification);
    // _requestPermissions();
    // firebaseMessaging!.getToken().then((String? token) {
    //   assert(token != null);
    //   tokenfirebase = token;
    // });
  }
  void _requestPermissions() {
    flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              print('click mess ios');
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    print('clicked notification');
    // Navigator.push(
    //   _keymain.currentContext,
    //   MaterialPageRoute(
    //       builder: (context) =>
    //           ThongTinDuThaoWidget(idDuThao: payload)),
    // );
  }
  int index = 0;
  showNotification(Map<String, dynamic> message) async {
    var android = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer",
        priority: Priority.high, importance: Importance.max);
    //var iOS = new IOSNotificationDetails ();
    var platform = new NotificationDetails(android: android,);

    if(Platform.isIOS){
      await flutterLocalNotificationsPlugin!.show(
          index++,
          message['aps']['title'],
          message['aps']['body'],
          platform,
          payload: message["id"]);
    }
    else{
      await flutterLocalNotificationsPlugin!.show(
          index++,
          message['notification']['title'],
          message['notification']['body'],
          platform,
          payload: message["data"]["id"]);
    }
  }

  // pushNotification() async {
  //   firebaseMessaging.subscribeToTopic("qlvb");
  //   firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic>? message) async {
  //       print("onMessage: $message");
  //       showNotification(message);
  //     },
  //     onBackgroundMessage: myBackgroundMessageHandler,
  //     onLaunch: (Map<String, dynamic> message) async {
  //       // Navigator.push(
  //       //     context,
  //       //       MaterialPageRoute(
  //       //           builder: (context) =>
  //       //               ThongTinDuThaoWidget(idDuThao: message["data"]["id"]))
  //       // );
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print(message);
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //         builder: (context) =>
  //       //             ThongTinDuThaoWidget(idDuThao: message["data"]["id"]))
  //       // );
  //     },
  //   );
  //   firebaseMessaging.requestNotificationPermissions(
  //       const IosNotificationSettings(
  //           sound: true, badge: true, alert: true, provisional: true));
  //   firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {
  //     print("Settings registered: $settings");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return  Provider(
      create:(_) =>TaskDatabase() ,
      // builder: (_) =>TaskDatabase() ,
      child:  MaterialApp(
        home: Scaffold(
          key: _keymain,
          body: isLogin == true ? BottomNavigator() : LoginWidget() ,
        ),
        builder: (BuildContext context, Widget? child) {
          return FlutterEasyLoading(child: child);
        },
      ),
    );
  }
}