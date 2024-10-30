// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
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

class EditChannelDetails extends ConsumerStatefulWidget {
  final String? groupName;
  final String? groupDesc;
  final String? groupType;
  final String? groupID;
  final String currentUserNo;
  final bool isadmin;
  final SharedPreferences prefs;
  const EditChannelDetails(
      {super.key,
      this.groupName,
      this.groupDesc,
      required this.isadmin,
      required this.prefs,
      this.groupID,
      this.groupType,
      required this.currentUserNo});
  @override
  ConsumerState createState() => EditChannelDetailsState();
}

class EditChannelDetailsState extends ConsumerState<EditChannelDetails> {
  TextEditingController? controllerName = TextEditingController();
  TextEditingController? controllerDesc = TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeDesc = FocusNode();

  String? groupTitle;
  String? groupDesc;
  String? groupType;
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  void initState() {
    super.initState();
    Lamat.internetLookUp();
    groupDesc = widget.groupDesc;
    groupTitle = widget.groupName;
    groupType = widget.groupType;
    controllerName!.text = groupTitle!;
    controllerDesc!.text = groupDesc!;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    groupTitle =
        controllerName!.text.isEmpty ? groupTitle : controllerName!.text;
    groupDesc = controllerDesc!.text.isEmpty ? groupDesc : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectionchannels)
        .doc(widget.groupID)
        .update({
      Dbkeys.groupNAME: groupTitle,
      Dbkeys.groupDESCRIPTION: groupDesc,
      Dbkeys.groupTYPE: groupType,
    }).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc('${time.millisecondsSinceEpoch}--${widget.currentUserNo}')
          .set({
        Dbkeys.groupmsgCONTENT: widget.isadmin
            ? LocaleKeys.channelDetUpd.tr()
            : '${widget.currentUserNo} has updated Channel details',
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.groupmsgSENDBY: widget.currentUserNo,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails,
      });
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Lamat.toast(err.toString());
    });
  }

  void _handleTypeChange(String value) {
    setState(() {
      groupType = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (IsBannerAdShow == true) {
      myBanner.dispose();
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
                LocaleKeys.channeledit.tr(),
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
                    LocaleKeys.save.tr(),
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
                        style: TextStyle(
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        controller: controllerName,
                        validator: (v) {
                          return v!.isEmpty
                              ? LocaleKeys.validdetails.tr()
                              : null;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(6),
                          labelStyle: const TextStyle(
                            height: 0.8,
                            color: AppConstants.primaryColor,
                          ),
                          labelText: LocaleKeys.channelName.tr(),
                        ),
                      )),
                      const SizedBox(
                        height: 30,
                      ),
                      ListTile(
                          title: TextFormField(
                        minLines: 1,
                        maxLines: 10,
                        style: TextStyle(
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        controller: controllerDesc,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(6),
                          labelStyle: const TextStyle(
                              height: 0.8, color: AppConstants.primaryColor),
                          labelText: LocaleKeys.channeldesc.tr(),
                        ),
                      )),
                      const SizedBox(
                        height: 15,
                      ),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null
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
