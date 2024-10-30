// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/views/profile_settings/profile_view.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';

class GroupChatBubble extends ConsumerWidget {
  const GroupChatBubble(
      {super.key,
      required this.child,
      required this.isURLtext,
      required this.timestamp,
      required this.delivered,
      required this.isMe,
      required this.isContinuing,
      required this.messagetype,
      required this.postedbyname,
      required this.prefs,
      required this.postedbyphone,
      this.savednameifavailable,
      required this.model,
      required this.currentUserNo,
      required this.is24hrsFormat});
  final dynamic isURLtext;
  final dynamic messagetype;
  final int? timestamp;
  final Widget child;
  final dynamic delivered;
  final String postedbyname;
  final String postedbyphone;
  final String? savednameifavailable;
  final bool isMe, isContinuing;
  final DataModel model;
  final SharedPreferences prefs;
  final String currentUserNo;
  final bool is24hrsFormat;
  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp!));

  @override
  Widget build(BuildContext context, ref) {
    final contactsProvider = ref.watch(smartContactProvider);
    final bg =
        isMe ? AppConstants.lamatCHATBUBBLEcolor : AppConstants.lamatWhite;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    dynamic icon = Icons.done_all;
    final color = isMe
        ? AppConstants.lamatBlack.withOpacity(0.5)
        : AppConstants.lamatBlack.withOpacity(0.5);
    icon = Icon(icon, size: 14.0, color: color);
    if (delivered is Future) {
      icon = FutureBuilder(
          future: delivered,
          builder: (context, res) {
            switch (res.connectionState) {
              case ConnectionState.done:
                return Icon((Icons.done_all), size: 13.0, color: color);
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
              default:
                return Icon(Icons.access_time, size: 13.0, color: color);
            }
          });
    }
    dynamic radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    dynamic margin = const EdgeInsets.only(top: 20.0, bottom: 1.5);
    if (isContinuing) {
      radius = const BorderRadius.all(Radius.circular(5.0));
      margin = const EdgeInsets.all(1.9);
    }

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: margin,
          padding: const EdgeInsets.all(8.0),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.67),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: align,
                children: [
                  isMe
                      ? Container(
                          width: 110,
                        )
                      : FutureBuilder<LocalUserData?>(
                          future:
                              contactsProvider.fetchUserDataFromnLocalOrServer(
                                  prefs, postedbyphone),
                          builder: (context,
                              AsyncSnapshot<LocalUserData?> snapshot) {
                            if (snapshot.hasData) {
                              return InkWell(
                                onTap: () async {
                                  hidekeyboard(context);
                                  await contactsProvider
                                      .fetchFromFiretsoreAndReturnData(
                                          prefs, snapshot.data!.id, (doc) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileView(
                                                doc.data()!,
                                                currentUserNo,
                                                model,
                                                prefs,
                                                const [],
                                                firestoreUserDoc: null)));
                                  });
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.67,
                                  child: Text(
                                    savednameifavailable ?? snapshot.data!.name,
                                    style: TextStyle(
                                        color: randomColorgenrator(int.tryParse(
                                                        postedbyphone.substring(
                                                            5, 6))!
                                                    .remainder(2) ==
                                                0
                                            ? int.tryParse(postedbyphone
                                                    .substring(5, 6))!
                                                .remainder(2)
                                            : int.tryParse(postedbyphone
                                                    .substring(7, 8))!
                                                .remainder(2)),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.67,
                              child: Text(
                                savednameifavailable ?? postedbyphone,
                                style: TextStyle(
                                    color: randomColorgenrator(int.tryParse(
                                                    postedbyphone.substring(
                                                        5, 6))!
                                                .remainder(2) ==
                                            0
                                        ? int.tryParse(
                                                postedbyphone.substring(5, 6))!
                                            .remainder(2)
                                        : int.tryParse(
                                                postedbyphone.substring(7, 8))!
                                            .remainder(2)),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                  //------

                  isMe
                      ? const SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : const SizedBox(
                          height: 10,
                        ),
                  Padding(
                      padding: messagetype == null ||
                              messagetype == MessageType.location ||
                              messagetype == MessageType.image ||
                              messagetype == MessageType.video
                          ? child is Container
                              ? const EdgeInsets.fromLTRB(0, 0, 0, 27)
                              : EdgeInsets.only(
                                  right: messagetype == MessageType.location
                                      ? 0
                                      : isMe
                                          ? is24hrsFormat == true
                                              ? 50
                                              : 65.0
                                          : is24hrsFormat == true
                                              ? 36
                                              : 50.0)
                          : child is Container
                              ? const EdgeInsets.all(0.0)
                              : EdgeInsets.only(
                                  right: isMe ? 5.0 : 5.0, bottom: 25),
                      child: child),
                ],
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          getWhen(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp!),
                                  context) +
                              ', ',
                          style: TextStyle(
                            color: color,
                            fontSize: 11.0,
                          )),
                      Text(' ${humanReadableTime()}${isMe ? ' ' : ''}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11.0,
                          )),
                      isMe ? icon : const SizedBox()
                      // ignore: unnecessary_null_comparison
                    ].where((o) => o != null).toList()),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Color randomColorgenrator(int digit) {
    switch (digit) {
      case 1:
        {
          return Colors.red;
        }

      case 2:
        {
          return Colors.blue;
        }
      case 3:
        {
          return Colors.purple;
        }
      case 4:
        {
          return AppConstants.lamatGreenColor500;
        }
      case 5:
        {
          return Colors.orange;
        }
      case 6:
        {
          return Colors.cyan;
        }
      case 7:
        {
          return Colors.pink;
        }
      case 8:
        {
          return Colors.red;
        }
      case 9:
        {
          return Colors.red;
        }

      default:
        {
          return Colors.blue;
        }
    }
  }
}
