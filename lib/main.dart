import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qlvbbotuphap/Login.dart';
import 'package:qlvbbotuphap/btnavigator_widget.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';
import 'package:qlvbbotuphap/local_notification_service.dart';
import 'package:qlvbbotuphap/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> backgroundHandler(RemoteMessage message) async{
  print(message.data.toString());
  print(message.notification!.title);
  await Firebase.initializeApp();
}
const debug = true;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
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

  void initState() {
    super.initState();
    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    AndroidInitializationSettings('@mipmap/ic_launcher');
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message != null){
        final routeFromMessage = message.data["route"];
      }
    });

    ///foreground
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification != null){
        print(message.notification?.body);
        print(message.notification?.title);
      }

      LocalNotificationService.display(message);
    });
    ///open app
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];

      Navigator.of(context).pushNamed(routeFromMessage);
    });

    FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    if(Platform.isIOS){

      FirebaseMessaging.instance.getAPNSToken().then((value){
        print("token key =" + value.toString());
        tokenfirebase = value.toString();
      });
      FirebaseMessaging.instance.getToken().then((value){
        print("token key1 =" + value.toString());
        tokenfirebase = value.toString();
      });
      //
      // FirebaseMessaging.instance.getAPNSToken().then((value){
      //   print("token key =" + value.toString());
      // tokenDevice = value.toString();
      // });
    }else{
      FirebaseMessaging.instance.getToken().then((value){
        print("token key2 =" + value.toString());
        tokenfirebase = value.toString();
      });
    }


    if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

    }
  }
  @override
  // void initState() {
  //   super.initState();
  //
  //   //pushNotification();
  //   flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  //   AndroidInitializationSettings initializationSettingsAndroid =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //   // final IOSInitializationSettings initializationSettingsIOS =
  //   // // IOSInitializationSettings(
  //   // //     requestSoundPermission: true,
  //   // //     requestBadgePermission: true,
  //   // //     requestAlertPermission: true,
  //   // //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  //   // var initSetttings = new InitializationSettings(
  //   //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //   // // flutterLocalNotificationsPlugin!.initialize(initSetttings,
  //   // //     onSelectNotification: onSelectNotification);
  //   // _requestPermissions();
  //   FirebaseMessaging.instance.getToken().then((String? token) {
  //     assert(token != null);
  //     tokenfirebase = token;
  //   });
  // }
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