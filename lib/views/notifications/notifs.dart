import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/providers/notifications_stream.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/notifications/notif_viewer.dart';

class AllNotifications extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  const AllNotifications({super.key, required this.prefs});

  @override
  AllNotificationsState createState() => AllNotificationsState();
}

class AllNotificationsState extends ConsumerState<AllNotifications> {
  List notificationList = [];
  bool isloading = true;
  String errormessage = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              title: Text(
                LocaleKeys.notifications.tr(),
                style: TextStyle(
                  fontSize: 18,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
            ),
            body: ref.watch(notificationsProvider).when(
                  data: (snapshot) {
                    if (snapshot.exists) {
                      List list = snapshot.data()!['list'];
                      List notificationList = list.reversed.toList();
                      if (notificationList.isNotEmpty) {
                        return ListView.builder(
                          itemCount: notificationList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return notificationcard(doc: notificationList[i]);
                          },
                        );
                      } else {
                        return Center(
                            child: NoItemFoundWidget(
                                text: LocaleKeys.nonotifications.tr()));
                      }
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(
                            LocaleKeys.notifDocNotExists.tr(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.secondaryColor),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Text(
                        '${LocaleKeys.errorOccured.tr()} ${LocaleKeys.error.tr()} $error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ))));
  }

  //widget to show name in card
  Widget notificationcard({
    var doc,
  }) {
    return doc.containsKey(Dbkeys.nOTIFICATIONxxtitle)
        ? Stack(
            children: [
              InkWell(
                onTap: () {
                  notificationViwer(
                      context,
                      doc[Dbkeys.nOTIFICATIONxxdesc],
                      doc[Dbkeys.nOTIFICATIONxxtitle],
                      doc[Dbkeys.nOTIFICATIONxximageurl],
                      formatTimeDateCOMLPETEString(
                          context: context,
                          isdateTime: false,
                          timestamptargetTime:
                              doc[Dbkeys.nOTIFICATIONxxlastupdate]),
                      widget.prefs);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  decoration: boxDecoration(
                      showShadow: true,
                      bgColor: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                doc[Dbkeys.nOTIFICATIONxxtitle] ?? '',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  fontSize: 15.9,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                doc[Dbkeys.nOTIFICATIONxxdesc] ?? '',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  height: 1.35,
                                  fontSize: 14,
                                  color: AppConstants.lamatGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                          const SizedBox(
                            width: 12,
                          ),
                          doc[Dbkeys.nOTIFICATIONxximageurl] == null
                              ? const SizedBox()
                              : Container(
                                  height: 60,
                                  width: 110,
                                  color: Colors.white.withOpacity(0.19),
                                  child: doc[Dbkeys.nOTIFICATIONxximageurl] ==
                                          null
                                      ? Center(
                                          child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            LocaleKeys.noMediafound.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                                    .withOpacity(0.5)),
                                          ),
                                        ))
                                      : Image.network(
                                          doc[Dbkeys.nOTIFICATIONxximageurl],
                                          height: 60,
                                          width: 110,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                        ],
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3, 0, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTimeDateCOMLPETEString(
                                  context: context,
                                  isdateTime: false,
                                  timestamptargetTime:
                                      doc[Dbkeys.nOTIFICATIONxxlastupdate]),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontStyle: FontStyle.normal,
                                height: 1.25,
                                fontSize: 12.4,
                                color: Colors.blueGrey.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  BoxDecoration boxDecoration(
      {double? radius,
      Color? color,
      required Color bgColor,
      var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        //gradient: LinearGradient(colors: [bgColor, whiteColor]),
        boxShadow: showShadow == true
            ? [
                BoxShadow(
                    color: bgColor.withOpacity(0.4),
                    blurRadius: 0.5,
                    spreadRadius: 1)
              ]
            : [BoxShadow(color: bgColor)],
        border: showShadow == true
            ? Border.all(
                color: bgColor.withOpacity(0.99),
                style: BorderStyle.solid,
                width: 0)
            : Border.all(
                color: color ?? bgColor.withOpacity(0.9),
                style: BorderStyle.solid,
                width: 1.2),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 5)));
  }

  String formatTimeDateCOMLPETEString({
    required BuildContext context,
    Timestamp? timestamptargetTime,
    DateTime? datetimetargetTime,
    // int myTzoMinutes,
    bool? isdateTime,
    bool? isshowutc,
  }) {
    final observer = ref.watch(observerProvider);

    int myTzoMinutes = DateTime.now().timeZoneOffset.inMinutes;
    // var myTzoMinutes = 330;
    DateTime sortedTime = isdateTime == true || isdateTime == null
        ? datetimetargetTime!.add(Duration(
            minutes:
                myTzoMinutes - datetimetargetTime.timeZoneOffset.inMinutes))
        : timestamptargetTime!.toDate().add(Duration(
            minutes: myTzoMinutes -
                timestamptargetTime.toDate().timeZoneOffset.inMinutes));

    final df = DateFormat(observer.is24hrsTimeformat == true
        ? 'dd MMM yyyy,  HH:mm'
        : 'dd MMM yyyy  hh:mm a');

    return isshowutc == true
        ? myTzoMinutes >= 0
            ? '${df.format(sortedTime)} (GMT+${minutesToHour(myTzoMinutes)})'
            : '${df.format(sortedTime)} (GMT${minutesToHour(myTzoMinutes)})'
        : df.format(sortedTime);
  }

//--------------------
  String minutesToHour(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2)}:${parts[1].padLeft(2, '0')}';
  }
}
