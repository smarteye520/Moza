import 'package:mozaconnect/locator.dart';
import 'package:mozaconnect/Services/PushNotificationService.dart';
import 'package:flutter/material.dart';

class PushNotificationManager extends StatefulWidget {
  final Widget child;
  PushNotificationManager({Key key, this.child}) : super(key: key);

  _PushNotificationManagerState createState() =>
      _PushNotificationManagerState();
}

class _PushNotificationManagerState extends State<PushNotificationManager> {
  _PushNotificationManagerState() {
    print('_PushNotificationManagerState | Constructed');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    locator<PushNotificationService>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
