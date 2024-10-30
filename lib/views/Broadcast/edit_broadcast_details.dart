// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBroadcastDetails extends ConsumerStatefulWidget {
  final String? broadcastName;
  final String? broadcastDesc;
  final String? broadcastID;
  final String currentUserNo;
  final SharedPreferences prefs;
  final bool isadmin;
  const EditBroadcastDetails(
      {super.key,
      this.broadcastName,
      this.broadcastDesc,
      required this.isadmin,
      required this.prefs,
      this.broadcastID,
      required this.currentUserNo});
  @override
  ConsumerState createState() => EditBroadcastDetailsState();
}

class EditBroadcastDetailsState extends ConsumerState<EditBroadcastDetails> {
  TextEditingController? controllerName = TextEditingController();
  TextEditingController? controllerDesc = TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeDesc = FocusNode();

  String? broadcastTitle;
  String? broadcastDesc;
  BannerAd? myBanner;
  AdWidget? adWidget;
  @override
  void initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    Lamat.internetLookUp();
    broadcastDesc = widget.broadcastDesc;
    broadcastTitle = widget.broadcastName;
    controllerName!.text = broadcastTitle!;
    controllerDesc!.text = broadcastDesc!;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true &&
          observer.isadmobshow == true &&
          myBanner != null) {
        if (!kIsWeb) {
          myBanner!.load();
          adWidget = AdWidget(ad: myBanner!);
          setState(() {});
        }
      }
    });
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    broadcastTitle =
        controllerName!.text.isEmpty ? broadcastTitle : controllerName!.text;
    broadcastDesc = controllerDesc!.text.isEmpty ? '' : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .doc(widget.broadcastID)
        .update({
      Dbkeys.broadcastNAME: broadcastTitle,
      Dbkeys.broadcastDESCRIPTION: broadcastDesc,
    }).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(widget.broadcastID)
          .collection(DbPaths.collectionbroadcastsChats)
          .doc('${time.millisecondsSinceEpoch}--${widget.currentUserNo}')
          .set({
        Dbkeys.broadcastmsgCONTENT: widget.isadmin
            ? "Broadcast Details updated by Admin"
            : '${widget.currentUserNo} updated the Broadcast Details',
        Dbkeys.broadcastmsgLISToptional: [],
        Dbkeys.broadcastmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.broadcastmsgSENDBY: widget.currentUserNo,
        Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgTYPE:
            Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcastDetails,
      });
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Lamat.toast(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (IsBannerAdShow == true && myBanner != null && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              titleSpacing: 0,
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              title: Text(
                "Edit Broadcast",
                style: TextStyle(
                  fontSize: 20.0,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'save'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.primaryColor
                          : pickTextColorBasedOnBgColorAdvanced(
                              AppConstants.backgroundColor),
                    ),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 25,
                      ),
                      ListTile(
                          title: TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: controllerName,
                        validator: (v) {
                          return v!.isEmpty ? "Enter valid details" : null;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(6),
                          labelStyle: TextStyle(height: 0.8),
                          labelText: "Broadcast Name",
                        ),
                      )),
                      const SizedBox(
                        height: 30,
                      ),
                      ListTile(
                          title: TextFormField(
                        minLines: 1,
                        maxLines: 10,
                        controller: controllerDesc,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(6),
                          labelStyle: TextStyle(height: 0.8),
                          labelText: "Broadcast Description",
                        ),
                      )),
                      const SizedBox(
                        height: 85,
                      ),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null &&
                              myBanner != null &&
                              !kIsWeb
                          ? Container(
                              height: MediaQuery.of(context).size.width - 30,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(
                                bottom: 5.0,
                                top: 2,
                              ),
                              child: adWidget!)
                          : const SizedBox(
                              height: 0,
                            ),
                    ],
                  ),
                ),
                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          color: pickTextColorBasedOnBgColorAdvanced(
                                  !Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor)
                              .withOpacity(0.6),
                          child: const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppConstants.secondaryColor)),
                          ))
                      : Container(),
                ),
              ],
            ))));
  }
}
