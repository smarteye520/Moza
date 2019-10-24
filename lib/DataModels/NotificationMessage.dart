import 'package:mozaconnect/Tools/Helpers.dart';
import 'package:flutter/rendering.dart';

class NotificationMessage {
  String mobileAppNotificationId;
  String mobileAppButtonId;
  DateTime notificationWindowStart;
  DateTime notificationWindowEnd;
  int transitions;
  int transitionTime;
  String color1;
  String color2;

  String title;
  String text;
  bool fade;

  NotificationMessage({
    this.mobileAppButtonId,
    this.notificationWindowStart,
    this.notificationWindowEnd,
    this.transitions,
    this.transitionTime,
    this.color1,
    this.color2,
    this.title,
    this.text,
    this.fade
  });

  NotificationMessage.fromMap(Map<dynamic, dynamic> map) {
    debugPrint('NotificationMessage | Serialize from Map: $map');

    mobileAppNotificationId = map['mobileAppNotificationId'].toString();
    mobileAppButtonId = map['mobileAppButtonId']?.toString();
    transitions = int.tryParse(map['transitions'].toString());
    color1 = map['color1'].toString();
    color2 = map['color2'].toString();
    transitionTime = int.tryParse(map['transitionTime'].toString());
    var startString = map['notificationWindowStart'].toString();
    var endString = map['notificationWindowEnd'].toString();

    notificationWindowStart = getDateFromString(startString);
    notificationWindowEnd = getDateFromString(endString);

    title = map['title'].toString();
    text = map['text'].toString();

    fade = map['fade'].toString().toLowerCase() == 'true';
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['mobileAppNotificationId'] = mobileAppNotificationId;
    map['mobileAppButtonId'] = mobileAppButtonId;
    map['notificationWindowStart'] = notificationWindowStart.toString();
    map['notificationWindowEnd'] = notificationWindowEnd.toString();
    map['transitions'] = transitions;
    map['transitionTime'] = transitionTime;
    map['color1'] = color1;
    map['color2'] = color2;
    map['title'] = title;
    map['text'] = text;
    map['fade'] = fade;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
