import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:lamatdating/constants.dart';

Future<void> checkNotificationPermission(BuildContext context) async {
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("Notifications"),
            content: const Text(
                "$Appname needs to access your notifications to show you the latest messages and updates."),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text("Allow"),
                onPressed: () {
                  AwesomeNotifications().requestPermissionToSendNotifications();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  });
}

Future<bool> listenToNotification({
  required Future<void> Function(ReceivedAction)? onData,
  required Future<void> Function(ReceivedAction)? onDone,
}) {
  return AwesomeNotifications().setListeners(
    onActionReceivedMethod: onData!,
    onDismissActionReceivedMethod: onDone!,
  );
}

// // // void createQuoteNotification() async {
// // //   debugPrint("Creating notification for quote");
// // //   await AwesomeNotifications().createNotification(
// // //     content: NotificationContent(
// // //       id: DateTime.now().millisecondsSinceEpoch ~/ 100000,
// // //       channelKey: 'quotes_channel',
// // //       title: 'Notification ${Random().nextInt(100)}',
// // //       body:
// // //           'This notification was schedule to repeat at every single minute at clock.',
// // //       category: NotificationCategory.Reminder,
// // //       wakeUpScreen: true,
// // //     ),
// // //     schedule: NotificationCalendar(
// // //       second: 0,
// // //       timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
// // //       repeats: true,
// // //     ),
// // //   );
// // // }

// // // void cancelQuoteNotifications() async {
// // //   debugPrint("Cancelling quote notifications");
// // //   await AwesomeNotifications()
// // //       .cancelNotificationsByChannelKey("quotes_channel");
// // // }
