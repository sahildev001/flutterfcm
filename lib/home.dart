import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_database/firebase_database.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  TextEditingController textEditingMessageController = TextEditingController();
  TextEditingController textEditingTokenController = TextEditingController();
  String topic = "sahilfcm";
  FirebaseDatabase database = FirebaseDatabase.instance;
  String? fcmToken;

  void getNotification() async{
 fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: "BJShF9zENLfppTL8X4xnvPFaN77tVCJBXSVHSrrQkEgPBQstS5TP5KET7zLmdd518nivf7v1M3UHUffuK2YDSNE"
    );

    print("${Random().nextInt(200)}");
    await database.ref("Users").child("$fcmToken").push().set({
      "device_type": "${kIsWeb ? "web" : Platform.operatingSystem}",
      "token": "${fcmToken}"
    });
    print("fcm token :- ${fcmToken}");
    textEditingTokenController.text = fcmToken ?? "";
  }




  @override
  void initState() {


    getNotification();
    if (kIsWeb) {
      subscribeTopic(true);
    }else {
      subscribeTopic(false);
    }
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      showOverlayNotification((context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: SafeArea(
            child: ListTile(
              leading: SizedBox.fromSize(
                  size: const Size(40, 40),
                  child: ClipOval(
                      child: Container(
                        color: Colors.black,
                      ))),
              title: Text( "${message.data['title'] as String? ?? ""}"),
              subtitle: Text( message.data['message'] as String? ?? ""),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    OverlaySupportEntry.of(context)?.dismiss();
                  }),
            ),
          ),
        );
      }, duration: Duration(milliseconds: 4000));
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    super.initState();
  }


  subscribeTopic(bool isWeb) async{
    if(isWeb){
      subscribeTokenToTopic(fcmToken,topic);
    }else {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    }
  }


  subscribeTokenToTopic(token, topic) async {
    var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=AAAA-0jndpk:APA91bGHX22kpGxP5YbYvhOF3rKpHOAYN5vg6ThfGI1nsFW6OjJjFTn6-3x48cH8P1b8NO_kbhKqCYivZRaoY7bYLeyZyFjyznnAt7nB6ZkfA9Z0VWQZKsQLIKZiIttatFFDbix4Ollg'
    };
    var request = http.Request('POST', Uri.parse("https://iid.googleapis.com/iid/v1/${token}/rel/topics/${topic}"));
    request.headers.addAll(headers);
    await request.send().then((response) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
    print( "Error subscribing to topic: '+${response.statusCode} + ' - ' + ${response.reasonPhrase}");
    }else {
      print('Subscribed to "' + topic + '"');
    }
    } );

  }



 
  
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: AppBar(title: Text("fcm")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 9),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Message"
                  ),
                  controller: textEditingMessageController,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 9),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Token"
                  ),
                  controller: textEditingTokenController,
                ),
              ),
              SizedBox(height: 36,),
              InkWell(
                onTap: (){
                  if(textEditingMessageController.text == null || textEditingMessageController.text == ""){
                     toast("please enter message", duration: Toast.LENGTH_LONG,context: context);

                  }else {
                    callSendApi(
                        textEditingMessageController.text.toString(), "title",
                        textEditingTokenController.text.toString() == ""
                        || textEditingTokenController.text.toString() == null
                            ? topic
                            : textEditingTokenController.text.toString());
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 9,horizontal: 20),
                  color: Colors.blue,
                  child: Text("Submit"),
                ),
              )
            ],
          ),
        ),

    );

  }

 void callSendApi(String message,String title,String? to) async{
    print("to:-- ${to}");
   var headers = {
     'Content-Type': 'application/json',
     'Authorization': 'key=AAAA-0jndpk:APA91bGHX22kpGxP5YbYvhOF3rKpHOAYN5vg6ThfGI1nsFW6OjJjFTn6-3x48cH8P1b8NO_kbhKqCYivZRaoY7bYLeyZyFjyznnAt7nB6ZkfA9Z0VWQZKsQLIKZiIttatFFDbix4Ollg'
   };
   var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
   request.body = json.encode({
     "data": {
       "tittle": "${title}",
       "message": "${message}"
     },
     "to": "${to}"
   });
   request.headers.addAll(headers);

   http.StreamedResponse response = await request.send();

   if (response.statusCode == 200) {
     print(await response.stream.bytesToString());
   }
   else {
   print(response.reasonPhrase);
   }
 }

}
