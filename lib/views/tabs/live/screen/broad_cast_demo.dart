import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/broad_cast_top_bar_area.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_bottom_filed.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_chat_list.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Replace with your provider details
final myProvider = Provider((ref) => MyProviderState());

class BroadcastDemo extends ConsumerStatefulWidget {
  final UserProfileModel user;
  const BroadcastDemo({super.key, required this.user});

  @override
  ConsumerState<BroadcastDemo> createState() => _BroadcastDemoState();
}

class _BroadcastDemoState extends ConsumerState<BroadcastDemo> {
  // Add any additional state variables here
  bool isGoLive = false;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      prefs = ref.watch(sharedPreferences).value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(myProvider); // Access provider state

    return (!isGoLive)
        ? Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    child: Center(
                      child: Row(children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              icMalaika,
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              icMalaika,
                            )),
                      ]),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      BroadCastTopBarArea(
                          flashFunc: () {},
                          switchCamFunc: () {},
                          user: widget.user,
                          channelId: "12345",
                          goalModel: GoalModel(
                            streamTitle: "Test",
                            streamGoal: 100,
                            streamGoalType: "diamonds",
                            goalDescription: "Test",
                          )),
                      const Spacer(),
                      const SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                double width =
                                    MediaQuery.of(context).size.width;
                                double height =
                                    MediaQuery.of(context).size.height;
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return PopScope(
                                         onPopInvokedWithResult: (popped, result) async {
                                          return;
                                        },
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10, sigmaY: 10),
                                          child: Dialog(
                                            insetPadding: EdgeInsets.symmetric(
                                                horizontal: width * .08),
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              height: kIsWeb
                                                  ? Responsive.isMobile(context)
                                                      ? height * .5
                                                      : height * .5
                                                  : height * .5,
                                              width: kIsWeb
                                                  ? Responsive.isMobile(context)
                                                      ? width * .8
                                                      : width * .5
                                                  : width * .8,
                                              decoration: BoxDecoration(
                                                color: Teme.isDarktheme(prefs!)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(22)),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Spacer(),
                                                  AppRes.appLogo != null
                                                      ? Image.network(
                                                          AppRes.appLogo!,
                                                          width: 120,
                                                          height: 120,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : Image.asset(
                                                          AppConstants.logo,
                                                          color: AppConstants
                                                              .primaryColor,
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.contain,
                                                        ),
                                                  const Spacer(),
                                                  const Divider(),
                                                  const Spacer(),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                      "${LocaleKeys.goLive.tr()}?",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Teme.isDarktheme(
                                                                prefs!)
                                                            ? AppConstants
                                                                .textColor
                                                            : AppConstants
                                                                .textColorLight,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                      LocaleKeys
                                                          .pleaseCheckThesePrivacyPolicyAndTermsOfUseBefore
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration.none,
                                                        color: Teme.isDarktheme(
                                                                prefs!)
                                                            ? AppConstants
                                                                .textColor
                                                            : AppConstants
                                                                .textColorLight,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const WebViewScreen(
                                                                      2),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            LocaleKeys.tnc.tr(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 3,
                                                        width: 3,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: AppConstants
                                                              .primaryColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          3)),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const PrivacyPolicyViewer(),
                                                              ));
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            LocaleKeys
                                                                .privacyPolicy
                                                                .tr(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          overlayColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .transparent),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            // goLiveTap();
                                                          },
                                                          child: Container(
                                                            height: 55,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: AppConstants
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                LocaleKeys.yes
                                                                    .tr(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          overlayColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .transparent),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            height: 55,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: AppConstants
                                                                  .secondaryColor,
                                                              borderRadius: BorderRadius
                                                                  .only(
                                                                      // bottomLeft: Radius.circular(20),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                LocaleKeys.no
                                                                    .tr(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    barrierDismissible: false);
                              },
                              text: LocaleKeys.goLive.tr(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultNumericValue),
                      // LiveStreamChatList(
                      //     commentList: model.commentList, pageContext: context),
                      // LiveStreamBottomField(
                      //   model: model,
                      // )
                    ],
                  ),
                )
              ],
            ))
        : Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    child: Center(
                      child: Row(children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              icMalaika,
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              icMalaika,
                            )),
                      ]),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      BroadCastTopBarArea(
                          channelId: "Test",
                          model: null,
                          user: widget.user,
                          goalModel: GoalModel(
                            streamTitle: "Test",
                            streamGoal: 100,
                            streamGoalType: "diamonds",
                            goalDescription: "Test",
                          )),
                      // const SizedBox(
                      //   height: AppConstants.defaultNumericValue / 2,
                      // ),
                      // Row(
                      //   children: [
                      //     LiveStreamTitleAndGoalArea(goal: model),
                      //   ],
                      // ),
                      const Spacer(),
                      LiveStreamChatList(
                          commentList: const [], pageContext: context),
                      const LiveStreamBottomField(
                        model: null,
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }
}

// Replace with your actual provider logic
class MyProviderState {
  String data = 'Initial Data'; // Initial state value

  // Add methods to update the state
}
