import 'package:mozaconnect/Widgets/FlashingIcon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info/package_info.dart';
import '../Routes/InitializationScreen.dart';
import 'package:flutter/material.dart';
import '../BpmData.dart';
import '../main.dart';
import 'dart:developer';

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

DateTime getDateFromString(String date) {
  var parsedTime = DateTime.tryParse(date);

  if (parsedTime != null) {
    return parsedTime;
  }
  print('Could not parse time string $date');
  return null;
}

// Added by Smarteye
class LastClicked {
  static String id = '';
}

Widget createButtonFromString(
  BuildContext context,
  String iconId,
  String link,
  String linkAction,
  double buttonBoundingBoxSize,
  Color buttonDrawingColor,
  Color buttonInteriorAreaColor,
  Color containerColor,
  String iconSvgUrl,
) {
  if (iconId == null) throw new ArgumentError.value("iconId cannot be null");
  if (iconId.length == 0)
    throw new ArgumentError.value("iconId cannot be empty");

  return FlashingIcon(
      iconId: iconId,
      link: link,
      linkAction: linkAction,
      buttonBoundingBoxSize: buttonBoundingBoxSize,
      iconColor: buttonDrawingColor,
      floatingActionButtonColor: buttonInteriorAreaColor,
      containerColor: containerColor,
      iconSvgUrl: iconSvgUrl);
}

Expanded createButtonRow(
    BuildContext context, MobileAppData data, int rowNumber) {
  if (rowNumber < 0 || rowNumber > 3) throw new ArgumentError.value(rowNumber);

  var ctr = MainAxisAlignment.center;
  var buttonFontSize = 20.0;
  var buttonTextColor = Colors.white;

  var buttonCells = new List<Column>();
  // Set our iterations through button indexes:
  // Row 1 = Indexes 0 - 2 (0 < 3)
  // Row 2 = Indexes 3 - 5 (3 < 6)
  // Row 3 = Indexes 6 - 8 (6 < 9)
  var start = ((rowNumber - 1) * 3);
  var stop = (rowNumber * 3);
  for (var i = start; i < stop; i++) {
    var link = data.mozaLinks[i].link;
    var button = createButtonFromString(
        context,
        data.mozaLinks[i].buttonId,
        link,
        data.mozaLinks[i].linkAction,
        data.mozaLinks[i].boundingBoxSize,
        data.mozaLinks[i].buttonDrawingColor,
        data.mozaLinks[i].buttonInteriorAreaColor,
        data.mozaLinkAreaBkgColor,
        data.mozaLinks[i].svgIconUrl);

    var btnImage = Padding(
//      padding: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.only(bottom: 6.0),
       child: button);

    if (link == null || link.length == 0) buttonTextColor = Color(0xFFaaaaaa);

    var btnText = Text(
      data.mozaLinks[i].text,
      style: TextStyle(color: buttonTextColor, fontSize: buttonFontSize),
      textAlign: TextAlign.center,
    );

    var btn = <Widget>[btnImage, btnText];
    var col = Column(mainAxisAlignment: ctr, children: btn);

    buttonCells.add(col);
  }

  var row = Row(mainAxisAlignment: ctr, children: <Widget>[
    Expanded(flex: 1, child: buttonCells[0]),
    Expanded(flex: 1, child: buttonCells[1]),
    Expanded(flex: 1, child: buttonCells[2])
  ]);

  return Expanded(flex: 1, child: row);
}

Column createScreenArea(BuildContext context) {
  var copyrightAreaBackgroundColor = Colors.black;

  var data = mobileAppDataUsed;

  // I used the Cache Network Image here that makes use of the Flutter cache manager
  // If we want more fine grained control over the caching time we can use the cache manager
  // directly. I have written this article (https://www.filledstacks.com/snippet/download-and-cache-files-in-flutter-using-cache-manager)
  // which shows how to setup a cache with custom durations and number of files that can be cached.
  var logoImage = CachedNetworkImage(
      imageUrl: data.logoUrl,
      placeholder: (context, url) => CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(data.mozaLinkAreaBkgColor),
          ),
      errorWidget: (context, url, error) => Icon(Icons.error));

  var copyrightTextColor = Colors.white;

  var versionString = '';
  log('About to check PackageInfo');
  if (packageInfo != null) {
    var sa = packageInfo.version.split('.');
    versionString = ' (v ${sa[0]}.${sa[1]})';
  }

  var copyrightText = Text('Copyright © 2019 MOZA Digital, LLC.$versionString',
      style: TextStyle(color: copyrightTextColor, fontSize: 18));

  var ctr = MainAxisAlignment.center;

  var buttonRow1 = createButtonRow(context, data, 1);
  var buttonRow2 = createButtonRow(context, data, 2);
  var buttonRow3 = createButtonRow(context, data, 3);

  Size screenSize = MediaQuery.of(context).size;

  double logoAreaHeight = (screenSize.height * 0.27).round().toDouble();
  double buttonAreaHeight = (screenSize.height * 0.69).round().toDouble();
  // Doing this to ensure no rounding errors
  double copyrightAreaHeight =
      screenSize.height - logoAreaHeight - buttonAreaHeight;

  log('Screen: ${screenSize.width.toString()} x ${screenSize.height.toString()}');
  log('Top:    ${logoAreaHeight.toString()}');
  log('Center: ${buttonAreaHeight.toString()}');
  log('Bottom: ${copyrightAreaHeight.toString()}');

  var logoArea = Container(
      alignment: Alignment.center,
      color: data.logoAreaBkgColor,
      padding: EdgeInsets.all(10.0),
      height: logoAreaHeight,
      width: screenSize.width,
      child: logoImage);

  var buttonArea = Container(
      color: data.mozaLinkAreaBkgColor,
      height: buttonAreaHeight,
      padding: EdgeInsets.only(top: 0, bottom: 0),
      width: screenSize.width,
      child: Column(
          mainAxisAlignment: ctr,
          children: <Widget>[buttonRow1, buttonRow2, buttonRow3]));

  var copyrightArea = Container(
    color: copyrightAreaBackgroundColor,
    height: copyrightAreaHeight,
    width: screenSize.width,
    child: copyrightText,
    alignment: Alignment(0.0, 0.0),
  );

  var screenArea = Column(
      mainAxisAlignment: ctr,
      children: <Widget>[logoArea, buttonArea, copyrightArea]);

  return screenArea;
}

getVersion(String versionString) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  log('Version: $appName,  $packageName, $version, $buildNumber');
}
