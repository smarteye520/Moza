import 'package:mozaconnect/main.dart';
import 'package:mozaconnect/Tools/Dialogs.dart';
import 'package:flutter/material.dart';
import '../Tools/Helpers.dart';
import 'package:mozaconnect/locator.dart';
import 'package:mozaconnect/Services/LocalStorageService.dart';

class BpmScreen extends StatefulWidget {
  BpmScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _BpmScreenState createState() => _BpmScreenState();
}

void onOpenMenu(BuildContext context) async {
  var result =
      await showInputDialog(context, 'Choose another App Code?', false);
  if (result == 'GO!') {
    // Clear out and restart
    var localStorageService = locator<LocalStorageService>();
    localStorageService.clearStoredNotification();
    localStorageService.appCode = null;
    RestartWidget.restartApp(context);
  }
}

class _BpmScreenState extends State<BpmScreen> {
  @override
  Widget build(BuildContext context) {
    var screenArea = createScreenArea(context);

    var menu = new Container(
      alignment: Alignment(0.98, -0.87),
      child: FittedBox(
        child: PopupMenuButton<int>(
          onSelected: (value) {
            if (value == 0) {
              onOpenMenu(context);
            }
            // TODO: Placeholder to display previous notification if still valid
            //  else if (value == 5) {
            //   var localStorageService = locator<LocalStorageService>();
            //   if (localStorageService.hasStoredNotification) {}
            // }
          },
          child: Icon(Icons.menu),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 0,
              child: Text("Change App Code"),
            ),
            // PopupMenuItem(
            //   value: 5,
            //   child: Text('Hot Link Deal!'),
            // ),
            PopupMenuItem(
              value: 10,
              child: Text('Version ${packageInfo.version}'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: screenArea,
      ),
      floatingActionButton: menu,
    );
  }
}
