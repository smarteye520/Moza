import 'dart:async';

import 'package:mozaconnect/DataModels/NotificationMessage.dart';
import 'package:mozaconnect/Widgets/CachedSvgImage.dart';
import 'package:mozaconnect/locator.dart';
import 'package:mozaconnect/Services/LocalStorageService.dart';
import 'package:mozaconnect/Tools/Dialogs.dart';
import 'package:mozaconnect/Tools/Helpers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

NotificationMessage fakeNotificationData = NotificationMessage(
    //mobileAppNotificationId: 'G6aYg0DWx9Qd60SCE8Df',
    mobileAppButtonId: 'lIk3AmDlTmSLhK6q7WJu',

    notificationWindowStart: DateTime.now(),
    notificationWindowEnd: DateTime.now()..add(Duration(days: 1)),

    transitions: 14,
    transitionTime: 200,
    color1: '#FF0000',
    color2: '#555500',
    title: 'Fake notification',
    text: 'Nothing much to see here. Just move along...',
    fade: false);

class FlashingIcon extends StatefulWidget {
  final String iconId;
  final String link;
  final String linkAction;
  final double buttonBoundingBoxSize;
  final Color iconColor;
  final Color floatingActionButtonColor;
  final Color containerColor;
  final String iconSvgUrl;
  final Function(String, String) onLaunchLink;

  FlashingIcon({
    @required this.iconId,
    this.link,
    this.linkAction,
    this.buttonBoundingBoxSize,
    this.iconColor = const Color(0xFFaaaaaa),
    this.floatingActionButtonColor = const Color(0xFFCCCCCC),
    this.containerColor,
    this.iconSvgUrl,
    this.onLaunchLink,
  });

  _FlashingIconState createState() => _FlashingIconState();
}

class _FlashingIconState extends State<FlashingIcon> with TickerProviderStateMixin {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  int numberOfAnimationCyclesLeft = -1;
  int transitionDuration;

  bool _animating = false;
  bool _disposed = false;

  Color flashingColor1;
  Color flashingColor2;

  Color currentIconColor;
  Color currentFloatingActionButtonColor;

  StreamSubscription<dynamic> _storageUpdateSubscription;

  // Added by Bailey
  AnimationController _controller;
  //Animation<double> size;

  @override
  void initState() {
    super.initState();

    // Added by Smarteye
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this
    );

    // size = Tween<double>(
    //   begin: 50.0,
    //   end: 67.0,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Interval(
    //       0.0, 1.0,
    //       curve: Curves.ease,
    //     ),
    //   ),
    // );

    _setOriginalColors();

    if (_localStorageService.hasStoredNotification) {
      _setAndStartAnimation();
    } else {
      _storageUpdateSubscription = _localStorageService.valueUpdated.listen((value) {
        if (value != null) {
          debugPrint('${widget.iconId}: Storage value updated. Value $value');
          _setAndStartAnimation(canSetState: true);
        } else {
          debugPrint('${widget.iconId}: Value null so set back to original colors');
          setState(() {
            _setOriginalColors();
          });
        }
      });
    }
  }

  void _setOriginalColors() {
    // debugPrint('${widget.iconName}: _setOriginalColors');
    currentIconColor = widget.iconColor;
    currentFloatingActionButtonColor = widget.floatingActionButtonColor;
  }

  void _setAndStartAnimation({bool canSetState = false}) {
    var notificationMessage = _localStorageService.savedNotification;

    if (notificationMessage == null) {
      return;
    }

    if (notificationMessage.mobileAppButtonId == widget.iconId && _isNotificationActive(notificationMessage)) {
      debugPrint('${widget.iconId}: _setAndStartAnimation with notification data: $notificationMessage');
      flashingColor1 = hexToColor(notificationMessage.color1);
      flashingColor2 = hexToColor(notificationMessage.color2);

      numberOfAnimationCyclesLeft = notificationMessage.transitions;
      transitionDuration = notificationMessage.transitionTime;

      _startFlashingCycle();
    } else if (canSetState) {
      debugPrint('${widget.iconId}: canSetState: $canSetState');
      setState(() {
        _setOriginalColors();
      });
    } else if (notificationMessage.notificationWindowEnd != null && DateTime.now().isAfter(notificationMessage.notificationWindowEnd)) {
      debugPrint('${widget.iconId}: date passed for notification. Current date: ${DateTime.now()}, End Date: ${notificationMessage.notificationWindowEnd}');
      _localStorageService.clearStoredNotification();
    }
  }

  bool _isNotificationActive(NotificationMessage notificationMessage) {
    return notificationMessage.notificationWindowStart != null &&
        notificationMessage.notificationWindowEnd != null &&
        _localStorageService.hasStoredNotification &&
        DateTime.now().isAfter(notificationMessage.notificationWindowStart) &&
        DateTime.now().isBefore(notificationMessage.notificationWindowEnd);
  }

  Future _startFlashingCycle({bool triggerAnimation = false}) async {
    // TODO: Change this to use animations for smooth transitions. When SVG color mask update it more effecient
    if (_animating) return;

    if (triggerAnimation) {
      _animating = true;
    }

    debugPrint('${widget.iconId}: _backgroundAnimationCycle START: $numberOfAnimationCyclesLeft animating: $_animating');
    do {
      if (!_disposed) {
        setState(() {
          if (numberOfAnimationCyclesLeft % 2 == 0) {
            currentIconColor = flashingColor1;
            currentFloatingActionButtonColor = flashingColor2;
          } else {
            currentIconColor = flashingColor2;
            currentFloatingActionButtonColor = flashingColor1;
          }
        });
      }
      await Future.delayed(Duration(milliseconds: transitionDuration));
      numberOfAnimationCyclesLeft--;
    } while (numberOfAnimationCyclesLeft > 0);

    _animating = false;
    debugPrint('${widget.iconId}: _backgroundAnimationCycle END: $numberOfAnimationCyclesLeft animating: $_animating');
  }

  @override
  Widget build(BuildContext context) {
    //var buttonSizeFactor = 0.61;
    return GestureDetector(
      onTap: () {

        // Added by Smarteye
        _playAnimation();
        LastClicked.id = widget.iconId;
        Timer(Duration(milliseconds: 800), () {launchLink(widget.link, widget.linkAction);});

        //launchLink(widget.link, widget.linkAction);
        if (_localStorageService.hasStoredNotification) {
          var localNotification = _localStorageService.savedNotification;

          if (localNotification.mobileAppButtonId == widget.iconId) {
            debugPrint('FlashingIcon | icon tapped: ${widget.iconId}');

            setState(() {
              _setOriginalColors();
            });

            var openedNotifications = _localStorageService.openedNotifications;
            openedNotifications.add(
                _localStorageService.savedNotification.mobileAppNotificationId);
            _localStorageService.openedNotifications = openedNotifications;
            debugPrint(
                'Added a new ID to the opened notifications. $openedNotifications');

            debugPrint('${widget.iconId}: Clear stored notification.');
            _localStorageService.clearStoredNotification();
          } else {
            setState(() {
              _setOriginalColors();
            });
          }
        }
      },
      // Added by Smarteye
      child: AnimatedButton(controller: _controller.view, iconSvgUrl: widget.iconSvgUrl, id: widget.iconId, curIconColor: currentIconColor, curFloatingActionButtonColor: currentFloatingActionButtonColor)      
      // child: FittedBox(
      //   child: Container(
      //     height: widget.buttonBoundingBoxSize,
      //     width: widget.buttonBoundingBoxSize,
      //     alignment: Alignment.center,
      //     decoration: BoxDecoration(
      //         color: currentFloatingActionButtonColor,
      //         borderRadius: BorderRadius.circular(
      //             widget.buttonBoundingBoxSize * buttonSizeFactor)),
      //     child: Container(
      //       width: widget.buttonBoundingBoxSize * buttonSizeFactor,
      //       height: widget.buttonBoundingBoxSize * buttonSizeFactor,
      //       child: CachedSvgImage(
      //         url: widget.iconSvgUrl,
      //         color: currentIconColor,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  // Added by Smarteye
  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  void launchLink(String link, String linkAction) async {
    if (link == null || link.length == 0) return;

    String linkToLaunch;

    if (linkAction == 'Call')
      linkToLaunch = 'tel:+1$link';
    else if (linkAction == 'Text')
      linkToLaunch = 'sms:+1$link';
    else if (linkAction == 'Email')
      linkToLaunch = 'mailto:$link';
    else
      linkToLaunch = link;

    if (await canLaunch(linkToLaunch)) {
      await launch(linkToLaunch);
      return;
    }

    String msg;
    if (linkAction == 'Text')
      msg = "Cannot send a message to:\r\n$link";
    else if (linkAction == 'Call')
      msg = "Cannot call:\r\n$link";
    else if (link.startsWith("mailto:"))
      msg = "We couldn't email\r\n$link";
    else
      msg = "We couldn't open:\r\n$link";

    showAlertDialog(context, "Ooops!", msg);
  }

  @override
  void dispose() {
    super.dispose();
    _storageUpdateSubscription?.cancel();
    _disposed = true;
  }
}

// Added by Smarteye
class AnimatedButton extends StatelessWidget {
  AnimatedButton({ Key key, this.controller, this.iconSvgUrl, this.id, this.curIconColor, this.curFloatingActionButtonColor}) :

  // Each animation defined here transforms its value during the subset
  // of the controller's duration defined by the animation's interval.
  // For example the opacity animation transforms its value during
  // the first 10% of the controller's duration.

        size = Tween<double>(
          begin: 50.0,
          end: 67.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0, 1.0,
              curve: Curves.ease,
            ),
          ),
        ),

  // ... Other tween definitions ...

        super(key: key);

  final Animation<double> controller;
  final Animation<double> size;
  final String iconSvgUrl;
  final String id;
  final Color curIconColor;
  final Color curFloatingActionButtonColor;

  // This function is called each time the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget child) {
    // child: FittedBox(
    //   child: Container(
    //     height: widget.buttonBoundingBoxSize,
    //     width: widget.buttonBoundingBoxSize,
    //     alignment: Alignment.center,
    //     decoration: BoxDecoration(
    //         color: currentFloatingActionButtonColor,
    //         borderRadius: BorderRadius.circular(
    //             widget.buttonBoundingBoxSize * buttonSizeFactor)),
    //     child: Container(
    //       width: widget.buttonBoundingBoxSize * buttonSizeFactor,
    //       height: widget.buttonBoundingBoxSize * buttonSizeFactor,
    //       child: CachedSvgImage(
    //         url: widget.iconSvgUrl,
    //         color: currentIconColor,
    //       ),
    //     ),
    //   ),
    // ),
    return FittedBox(
      child: Container(
        height: size.value + 15,
        width:  size.value + 15,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: curFloatingActionButtonColor,
            borderRadius: BorderRadius.circular(
                100)),
        child: Container(
          width: size.value,
          height: size.value,
          child: CachedSvgImage(
            url: iconSvgUrl,
            color: curIconColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
