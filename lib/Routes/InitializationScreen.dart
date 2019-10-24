import '../BpmData.dart';
import 'package:flutter/material.dart';

var checkingAppCode = false;

String appCodeUsed;
MobileAppData mobileAppDataUsed;

void onCheckAppCode(
    BuildContext context, String ignoreText, String textEntered) {
  if (checkingAppCode || textEntered.length == 0 || textEntered == ignoreText)
    return;

  checkingAppCode = true;

  appCodeUsed = textEntered;
  getFirestoreData(context, appCodeUsed);
}

class InitializationScreen extends StatelessWidget {
  final TextEditingController appCodeController = TextEditingController();
  final TextStyle style = TextStyle(fontFamily: 'Ariel', fontSize: 20.0);
  final String hintText = "App Code";

  @override
  Widget build(BuildContext context) {
    final appCodeField = TextField(
      controller: appCodeController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hintText,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
// TODO DANE: Provide feedback when tapped. Currently it's "stuck" until the data comes back.
// We should show a busy indicator
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          onCheckAppCode(context, hintText, appCodeController.text);
        },
        child: Text("Start MOZA Mobile App!",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Enter App Code",
//            textAlign: TextAlign.center,
                    style: style.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                SizedBox(height: 45.0), appCodeField,
                //SizedBox(height: 25.0),passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*

onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BpmScreen()),
                );
              }
*/
