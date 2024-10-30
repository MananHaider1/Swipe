// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/broad_cast_screen_view_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/livestream_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/broad_cast_top_bar_area.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_bottom_filed.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_chat_list.dart';
import 'package:lamatdating/views/settings/verification/verification_steps.dart';

class BroadCastScreen extends ConsumerStatefulWidget {
  final GoalModel? goalModel;
  final String? agoraToken;
  final String? channelName;
  final String? channelId;
  final UserProfileModel? registrationUser;
  final UserProfileModel? guestUser;
  final bool? isCoHost;
  final bool isHost;
  final String? thumbnail;

  const BroadCastScreen({
    super.key,
    required this.agoraToken,
    required this.channelName,
    required this.channelId,
    this.registrationUser,
    this.guestUser,
    this.goalModel,
    this.isCoHost,
    required this.isHost,
    this.thumbnail,
  });

  @override
  BroadCastScreenState createState() => BroadCastScreenState();
}

class BroadCastScreenState extends ConsumerState<BroadCastScreen> {
  String? agoraToken;
  String? channelName;
  String? channelId;
  bool isGoLive = false;

  late CameraController _cameraController;
  late Future<void> _cameraFuture;

  bool _isFlashlightOn = false;

  SharedPreferences? prefs;

  UserProfileModel? newUserProfile;

  @override
  void initState() {
    debugPrint(widget.goalModel.toString());
    (widget.isCoHost != null && widget.isCoHost == true)
        ? isGoLive = true
        : isGoLive = false;
    super.initState();
    _cameraFuture = _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      prefs = ref.watch(sharedPreferences).value;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController =
        CameraController(cameras.first, ResolutionPreset.veryHigh);
    return _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();

    // _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveConstants.hiveBox);
    newUserProfile = ref.watch(userProfileFutureProvider).value;
    void toggleFlashlight() {
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
        if (_isFlashlightOn) {
          _cameraController.setFlashMode(FlashMode.torch);
        } else {
          _cameraController.setFlashMode(FlashMode.off);
        }
      });
    }

    void flipCamera() async {
      final cameras = await availableCameras();
      if (cameras.length <= 1) return; // Early exit if only 1 camera

      final newCamera = CameraLensDirection.values.firstWhere(
        (lensDir) => lensDir != _cameraController.description.lensDirection,
        // orElse: (_) => null,
      );

      // ignore: unnecessary_null_comparison
      if (newCamera == null) return; // Early exit if no opposite camera

      await _cameraController.dispose();
      _cameraController = CameraController(
          cameras.firstWhere((camera) => camera.lensDirection == newCamera),
          ResolutionPreset.medium);
      await _cameraController.initialize();
      setState(() {});
    }

    void goLiveTap() async {
      widget.registrationUser!.isVerified
          ? {
              EasyLoading.show(),
              await LiveStream()
                  .generateAgoraToken(widget.registrationUser!.phoneNumber,
                      widget.registrationUser!.phoneNumber)
                  .then(
                (value) async {
                  if (value.token != "" && value.channelId != "") {
                    debugPrint(
                        "AgoraToken ====> ${value.token}\nchannelId ====> ${value.channelId}");

                    await box.put(HiveConstants.agoraToken, value.token);
                    await box.put(
                        HiveConstants.agoraChannelId, value.channelId);
                    setState(() {
                      agoraToken = value.token;
                      channelId = value.channelId;
                    });
                    if (kDebugMode) {
                      print("Update Agora Token in Profile");
                    }
                    await ref.read(userProfileNotifier).updateAgoraToken(
                        agoraToken: agoraToken,
                        phoneNumber: widget.registrationUser!.phoneNumber);
                    newUserProfile =
                        ref.refresh(userProfileFutureProvider).value;
                    EasyLoading.dismiss();
                    setState(() {
                      isGoLive = true;
                    });
                    _cameraController.dispose();
                  }
                },
              )
            }
          : showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: Text(LocaleKeys.getVerified.tr()),
                      content:
                          const Text("You need a verified account to go live"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(LocaleKeys.cancel.tr()),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GetVerifiedPage(
                                    user: widget.registrationUser!),
                              ),
                            );
                          },
                          child: Text(LocaleKeys.apply.tr()),
                        )
                      ]));
    }

    return !isGoLive
        ? Scaffold(
            resizeToAvoidBottomInset: true,
            body: FutureBuilder(
                future: _cameraFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text(
                          'Error initializing camera: ${snapshot.error}');
                    }
                    return Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: CameraPreview(_cameraController),
                        ),
                        SafeArea(
                          child: Column(
                            children: [
                              BroadCastTopBarArea(
                                  flashFunc: toggleFlashlight,
                                  switchCamFunc: flipCamera,
                                  user: widget.registrationUser!,
                                  channelId: widget.channelId,
                                  goalModel: widget.goalModel),
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
                                                onPopInvoked: (popped) async {
                                                  return;
                                                },
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 10),
                                                  child: Dialog(
                                                    insetPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * .08),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: Container(
                                                      height: kIsWeb
                                                          ? Responsive.isMobile(
                                                                  context)
                                                              ? height * .5
                                                              : height * .5
                                                          : height * .5,
                                                      width: kIsWeb
                                                          ? Responsive.isMobile(
                                                                  context)
                                                              ? width * .8
                                                              : width * .5
                                                          : width * .8,
                                                      decoration: BoxDecoration(
                                                        color: Teme.isDarktheme(
                                                                prefs!)
                                                            ? AppConstants
                                                                .backgroundColorDark
                                                            : AppConstants
                                                                .backgroundColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    22)),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          const Spacer(),
                                                          AppRes.appLogo != null
                                                              ? Image.network(
                                                                  AppRes
                                                                      .appLogo!,
                                                                  width: 120,
                                                                  height: 120,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                )
                                                              : Image.asset(
                                                                  AppConstants
                                                                      .logo,
                                                                  color: AppConstants
                                                                      .primaryColor,
                                                                  width: 90,
                                                                  height: 90,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                          const Spacer(),
                                                          const Divider(),
                                                          const Spacer(),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Text(
                                                              "${LocaleKeys.goLive.tr()}?",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
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
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Text(
                                                              LocaleKeys
                                                                  .pleaseCheckThesePrivacyPolicyAndTermsOfUseBefore
                                                                  .tr(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
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
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          const WebViewScreen(
                                                                              2),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .tnc
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
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
                                                                    horizontal:
                                                                        5),
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: AppConstants
                                                                      .primaryColor,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
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
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .privacyPolicy
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
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
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  overlayColor:
                                                                      MaterialStateProperty.all(
                                                                          Colors
                                                                              .transparent),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    goLiveTap();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 55,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppConstants
                                                                          .primaryColor,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        bottomLeft:
                                                                            Radius.circular(20),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        LocaleKeys
                                                                            .yes
                                                                            .tr(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          decoration:
                                                                              TextDecoration.none,
                                                                          color:
                                                                              Colors.white,
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
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  overlayColor:
                                                                      MaterialStateProperty.all(
                                                                          Colors
                                                                              .transparent),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 55,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppConstants
                                                                          .secondaryColor,
                                                                      borderRadius: BorderRadius.only(
                                                                          // bottomLeft: Radius.circular(20),
                                                                          bottomRight: Radius.circular(20)),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        LocaleKeys
                                                                            .no
                                                                            .tr(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          decoration:
                                                                              TextDecoration.none,
                                                                          color:
                                                                              Colors.white,
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
                              const SizedBox(
                                  height: AppConstants.defaultNumericValue),
                              // LiveStreamChatList(
                              //     commentList: model.commentList, pageContext: context),
                              // LiveStreamBottomField(
                              //   model: model,
                              // )
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }))
        : (newUserProfile != null)
            ? ViewModelBuilder<BroadCastScreenViewModel>.reactive(
                onViewModelReady: (model) async {
                  final agoraTokenCached =
                      await box.get(HiveConstants.agoraToken);
                  final channelIdCached =
                      await box.get(HiveConstants.agoraChannelId);
                  return model.init(
                      ref: ref,
                      isBroadCast: true,
                      isCoHost: widget.isCoHost ?? false,
                      agoraToken: widget.isCoHost ?? false
                          ? widget.agoraToken!
                          : agoraTokenCached,
                      channelName: widget.isCoHost ?? false
                          ? widget.channelId
                          : channelIdCached,
                      registrationUser: widget.isCoHost ?? false
                          ? widget.registrationUser
                          : newUserProfile,
                      guestUser: widget.guestUser,
                      context: context);
                },
                onDispose: (viewModel) {
                  viewModel.leave(context, ref);
                },
                viewModelBuilder: () => BroadCastScreenViewModel(
                    ref: ref,
                    isHost: widget.isHost,
                    thumbNail: widget.thumbnail,
                    isCoHost: widget.isCoHost ?? false,
                    channelId: channelId ?? widget.channelId,
                    userProfile: widget.isCoHost ?? false
                        ? widget.registrationUser!
                        : newUserProfile!,
                    goalModel: widget.goalModel),
                builder: (context, model, child) {
                  return PopScope(
                    canPop: false,
                    onPopInvoked: (pop) async {
                      model.onEndButtonClick(context, ref);
                      // return false;
                    },
                    child: Scaffold(
                      backgroundColor: AppConstants.backgroundColorDark,
                      body: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: model.videoPanel(context),
                          ),
                          SafeArea(
                            child: Column(
                              children: [
                                BroadCastTopBarArea(
                                    model: model,
                                    user: widget.isCoHost ?? false
                                        ? widget.registrationUser!
                                        : newUserProfile!,
                                    channelId: channelId ?? widget.channelId,
                                    goalModel: widget.goalModel),
                                // const SizedBox(
                                //   height: AppConstants.defaultNumericValue / 2,
                                // ),
                                // Row(
                                //   children: [
                                //     LiveStreamTitleAndGoalArea(goal: model),
                                //   ],
                                // ),
                                const Spacer(),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * .45,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppConstants.backgroundColorDark,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      LiveStreamChatList(
                                          commentList: model.commentList,
                                          pageContext: context),
                                      LiveStreamBottomField(
                                        model: model,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              );
  }
}

class LiveStreamTitleAndGoalArea extends StatelessWidget {
  final BroadCastScreenViewModel? goal;
  const LiveStreamTitleAndGoalArea({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
          left: AppConstants.defaultNumericValue / 2,
        ),
        // padding: const EdgeInsets.symmetric(
        //     horizontal: AppConstants.defaultNumericValue * 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.4),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        height: 60,
        // width: MediaQuery.of(context).size.width / 1.5,
        child: Row(children: [
          const SizedBox(
            width: 10,
          ),
          GifView.asset(
            coinsIcon,
            height: 50,
            width: 50,
            frameRate: 60, // default is 15 FPS
          ),
          goal != null
              ? goal!.liveStreamUser != null
                  ? goal!.liveStreamUser!.collectedDiamond != null
                      ? goal!.liveStreamUser!.collectedDiamond! /
                                  goal!.goalModel!.streamGoal <
                              1.0
                          ? Expanded(
                              child: LinearProgressIndicator(
                                value: goal!.liveStreamUser!.collectedDiamond! /
                                    goal!.goalModel!.streamGoal,
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 50,
                            )
                      : const Expanded(
                          child: LinearProgressIndicator(
                            value: 0.0,
                          ),
                        )
                  : const Expanded(
                      child: LinearProgressIndicator(
                        value: 0.0,
                      ),
                    )
              : const Expanded(
                  child: LinearProgressIndicator(
                    value: 0.0,
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
          Text(
            goal != null
                ? goal!.liveStreamUser != null
                    ? NumberFormat.compact(locale: 'en').format(double.parse(
                        '${goal!.liveStreamUser?.collectedDiamond ?? '0'}'))
                    : "0"
                : "0",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            width: 10,
          ),
        ]));
  }
}

class LiveStreamBattleGoalArea extends ConsumerStatefulWidget {
  final BroadCastScreenViewModel? goal;
  const LiveStreamBattleGoalArea({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<LiveStreamBattleGoalArea> createState() =>
      LiveStreamBattleGoalAreaState();
}

class LiveStreamBattleGoalAreaState
    extends ConsumerState<LiveStreamBattleGoalArea> {
  int collectedHost = 0;
  int collectedGuest = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // margin: const EdgeInsets.only(
        //   left: AppConstants.defaultNumericValue,
        // ),
        // padding: const EdgeInsets.symmetric(
        //     horizontal: AppConstants.defaultNumericValue * 3),
        // decoration: BoxDecoration(
        //   color: Colors.white.withOpacity(.4),
        //   borderRadius: const BorderRadius.all(
        //     Radius.circular(20),
        //   ),
        // ),
        height: 50,
        child: CoinBattleProgressBar(
          user1Coins: widget.goal != null
              ? widget.goal!.liveStreamUser!.collectedDiamond ?? 0
              : 1,
          user2Coins: widget.goal != null
              ? widget.goal!.liveStreamUser!.collectedDiamondGuest ?? 0
              : 2,
        ));
  }
}

class CoinBattleProgressBar extends StatefulWidget {
  final int user1Coins;
  final int user2Coins;

  const CoinBattleProgressBar(
      {super.key, required this.user1Coins, required this.user2Coins});

  @override
  State<CoinBattleProgressBar> createState() => _CoinBattleProgressBarState();
}

class _CoinBattleProgressBarState extends State<CoinBattleProgressBar> {
  double _user1Percentage = 0.5;

  @override
  void initState() {
    super.initState();
    _calculatePercentage();
  }

  void _calculatePercentage() {
    final totalCoins = widget.user1Coins + widget.user2Coins;
    if (totalCoins > 0) {
      _user1Percentage = widget.user1Coins / totalCoins;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: (_user1Percentage * 100).round(),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: AppConstants.defaultGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              // child: Center(
              //   child: Text('User 1: ${widget.user1Coins} Coins'),
              // ),
            ),
          ),
          Container(
              color: Colors.transparent,
              child: Center(
                child: Image.asset(icPurpleHeart, height: 40, width: 40),
              )),
          Expanded(
            flex: ((1 - _user1Percentage) * 100).round(),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: AppConstants.secondaryGradient,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              // child: Center(
              //   child: Text('User 2: ${widget.user2Coins} Coins'),
              // ),
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }
}
