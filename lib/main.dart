import 'package:flutter/services.dart';
import 'package:mozaconnect/Services/LocalStorageService.dart';
import 'package:mozaconnect/locator.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Managers/PushNotificationManager.dart';
import 'Routes/InitializationScreen.dart';

// Q: At what point will we allow users to select from different businesses?

PackageInfo packageInfo;

Future<void> main() async {
  try {
    packageInfo = await PackageInfo.fromPlatform();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await setupLocator();

    //runApp(BpmApp());

    runApp(new RestartWidget(child: BpmApp()));
  } catch (error) {
    print('Locator setup has failed. Most likely due to LocalStorage. $error');
  }
}

class BpmApp extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return PushNotificationManager(
      child: MaterialApp(
        title: 'MOZA Mobile App',
        home: _getStartUpScreen(buildContext),
      ),
    );
  }

  Widget _getStartUpScreen(BuildContext context) {
    var localStorageService = locator<LocalStorageService>();

    if (!localStorageService.hasAppCode) {
      return InitializationScreen();
    }

    // Return temp loading screen while we're fetching the data using the app code
    // we're using Builder here because of the onCheckAppCode requiring a context "below"
    // The navigator to make use of it through Navigator.of(context) for the navigation.
    // Will refactor to be loosly coupled to the firestore logic if we get there
    return Builder(
      builder: (context) {
        onCheckAppCode(context, 'App Code', localStorageService.appCode);

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Checking for latest data'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => new _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
}

/********************

Warning: FirebaseCorePlugin.java uses unchecked or unsafe operations.
Use Command Palette > Clear Edtitor History
(VSCODE) https://stackoverflow.com/questions/39234428/how-do-you-clear-your-visual-studio-code-cache-on-a-mac-linux-machine/42536001
(Android Studio) https://github.com/flutter/flutter/issues/28770

Updating project name
https://stackoverflow.com/questions/51534616/how-to-change-package-name-in-flutter/51550358

Updating displayed name
https://stackoverflow.com/questions/46694153/changing-the-project-name

********************/
