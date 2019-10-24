import 'package:mozaconnect/DataModels/NotificationMessage.dart';
import 'package:mozaconnect/Services/LocalStorageService.dart';
import 'package:mozaconnect/Services/PushNotificationService.dart';
import 'package:mozaconnect/Tools/Helpers.dart';
import 'package:mozaconnect/locator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Routes/BpmScreen.dart';
import 'Routes/InitializationScreen.dart';
import 'Tools/Dialogs.dart';

/*
firebase.firestore().collection('stuff').add({
  sort: firebase.firestore.FieldValue.serverTimestamp(),
});
*/

const String defaultSvgImage =
    'https://firebasestorage.googleapis.com/v0/b/mozasurvey.appspot.com/o/baywind-properties.png?alt=media&token=322457d2-137f-4436-9956-8cd331fe3203';

void getFirestoreData(BuildContext context, String appCode) async {
// The behavior for java.util.Date objects stored in Firestore is going to change AND YOUR APP MAY BREAK.
// To hide this warning and ensure your app does not break, you need to add the following code to your app before calling any other Cloud Firestore methods:

// It is safe to ignore these warnings: https://stackoverflow.com/questions/50639853/flutter-dart-app-breaking-due-to-change-on-firebase-date-object

/*

import 'package:cloud_firestore/cloud_firestore.dart';

Firestore.instance.collection('fields').where('grower', isEqualTo: 1)
    .snapshots().listen(
          (data) => print('grower ${data.documents[0]['name']}')
    );
*/

  locator<PushNotificationService>().subscribeToTopic(appCode);

  var col = Firestore.instance
      .collection("mobileApps")
      .where('mobileAppCode', isEqualTo: appCode)
      .getDocuments();

  col.then((docs) async {
    if (docs.documents.length == 0) {
      await showAlertDialog(
          context, "Oops!", "Sorry but we don't have that app code!");
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => InitializationScreen()));
    } else {
      var localStorageService = locator<LocalStorageService>();
      var pushnotificationService = locator<PushNotificationService>();

      var doc = docs.documents[0].data;
      mobileAppDataUsed = MobileAppData();
      Timestamp timestamp;
      try {
        Timestamp timestamp = doc["lastUpdateTimestamp"];
        mobileAppDataUsed.lastUpdated = timestamp.toDate();
      } catch (e) {
        print('Cannot parse Firestore timestamp ($timestamp) to a string');
      }

      mobileAppDataUsed.appCode = doc["mobileAppCode"];
      mobileAppDataUsed.company = doc["accountName"];
      var c = doc["linkAreaBkgColor"];
      mobileAppDataUsed.mozaLinkAreaBkgColorHex = c;
      mobileAppDataUsed.mozaLinkAreaBkgColor = hexToColor(c);
      c = doc["logoAreaBkgColor"];
      mobileAppDataUsed.logoAreaBkgColorHex = c;
      mobileAppDataUsed.logoAreaBkgColor = hexToColor(c);
      mobileAppDataUsed.logoUrl = doc["accountLogoImageUrl"];

      var notificationData = doc['notification'];
      if (notificationData != null) {
        print('NotificationData found | $notificationData');

        var notification = NotificationMessage.fromMap(notificationData);

        print('Notification Serialised | $notification');

        pushnotificationService.saveNotification(notification);
      }

      // Save app code to disk
      localStorageService.appCode = mobileAppDataUsed.appCode;

      for (var btn in doc["buttons"]) {
        ButtonData data = new ButtonData(
          70,
          btn["mobileAppButtonId"],
          btn["buttonAction"],
          btn["linkTarget"],
          btn["text"],
          btn["svgIcon"],
          hexToColor(btn["color1"]),
          hexToColor(btn["color2"]),
        );

        mobileAppDataUsed.mozaLinks.add(data);
      } // now here...?
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BpmScreen()));
      // }// was here...?
    }
    checkingAppCode = false;
  });
}

class ButtonData {
  double boundingBoxSize;
  String buttonId;
  String linkAction;
  String link;
  String text;
  String svgIconUrl;
  Color buttonDrawingColor = Colors.black;
  Color buttonInteriorAreaColor = Colors.white;

  ButtonData(
    this.boundingBoxSize,
    this.buttonId,
    this.linkAction,
    this.link,
    this.text,
    this.svgIconUrl,
    this.buttonDrawingColor,
    this.buttonInteriorAreaColor,
  );

  bool isSms() => linkAction == "Text";
  bool isPhone() => linkAction == "Call";
  bool isEmail() => linkAction == "Email";
  bool isHyperlink() => link.startsWith("http:") || link.startsWith("https:");

  // bool isSms() => link.startsWith("sms:");
  // bool isPhone() => link.startsWith("tel:");
  // bool isEmail() => link.startsWith("mailto:");
  // bool isHyperlink() => link.startsWith("http:") || link.startsWith("https:");
}

class MobileAppData {
  String appCode;
  String logoUrl;
  String company;
  String logoAreaBkgColorHex;
  String mozaLinkAreaBkgColorHex;
  Color logoAreaBkgColor = Colors.white;
  Color mozaLinkAreaBkgColor = Colors.red;
  DateTime lastUpdated;

  var mozaLinks = new List<ButtonData>();

  MobileAppData();

  MobileAppData.fromMap(Map<String, dynamic> map) {
    appCode = map['mobileAppCode'];
    logoUrl = map['accountLogoImageUrl'];
    company = map['accountName'];
    logoAreaBkgColorHex = map['logoAreaBkgColorHex'];
    mozaLinkAreaBkgColorHex = map['linkAreaBkgColorHex'];
    lastUpdated = map['lastUpdateTimestamp'];
  }

  Map<String, dynamic> toMap() {
    return {
      'mobileAppCode': appCode,
      'accountLogoImageUrl': logoUrl,
      'compaaccountNameny': company,
      'logoAreaBkgColorHex': logoAreaBkgColorHex,
      'linkAreaBkgColorHex': mozaLinkAreaBkgColorHex,
      'lastUpdateTimestamp': lastUpdated
    };
  }
}
