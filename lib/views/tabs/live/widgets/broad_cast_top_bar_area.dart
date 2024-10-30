// ignore_for_file: depend_on_referenced_packages

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gif_view/gif_view.dart';
// import 'package:intl/intl.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/views/tabs/profile/followers/followers_page.dart';
import 'package:restart_app/restart_app.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/broad_cast_screen_view_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/views/tabs/live/screen/broad_cast_screen.dart';
import 'package:lamatdating/views/tabs/live/widgets/end_dialog.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';

class BroadCastTopBarArea extends ConsumerWidget {
  final BroadCastScreenViewModel? model;
  final UserProfileModel user;
  final void Function()? flashFunc;
  final void Function()? switchCamFunc;
  final String? channelId;
  final GoalModel? goalModel;

  const BroadCastTopBarArea({
    super.key,
    this.model,
    required this.user,
    this.flashFunc,
    this.switchCamFunc,
    required this.channelId,
    required this.goalModel,
  });

  @override
  Widget build(BuildContext context, ref) {
    bool isMicOn = true;
    // bool isFrontCam = true;
    // bool isEndDialogOpen = false;
    void onEndButtonClick(BuildContext context) {
      // isEndDialogOpen = true;
      EasyLoading.dismiss();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          EasyLoading.dismiss();
          return EndDialog(
            false,
            onYesBtnClick: () async {
              await Restart.restartApp();
            },
          );
        },
      );
    }

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top + 10,
        ),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              UserCirlePicture(
                  imageUrl: user.profilePicture,
                  size: AppConstants.defaultNumericValue * 2.5),
              const SizedBox(
                width: 7,
              ),
              Text(
                user.userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
              const Spacer(
                flex: 4,
              ),
              Container(
                width: 60,
                height: 40,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      AppConstants.secondaryColor,
                      Color(0xFFFF3FC2),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        model != null
                            ? NumberFormat.compact(locale: 'en').format(
                                double.parse(
                                    '${model!.liveStreamUser?.watchingCount ?? '0'}'))
                            : "0",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  )),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  model == null
                      ? onEndButtonClick(context)
                      : model!.onEndButtonClick(context, ref);
                },
                child: Container(
                  padding: const EdgeInsets.all(11),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppConstants.secondaryGradient,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FollowersConsumerPage(
                          followers: user.followers!,
                          title: LocaleKeys.followers.tr(),
                          isInvite: true,
                          channelId: channelId,
                          goalModel: goalModel,
                          isHost: false,
                          isCoHost: true,
                          status: "pending"));
                },
                child: Container(
                    padding: const EdgeInsets.all(9),
                    // margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppConstants.defaultGradient,
                    ),
                    // alignment: Alignment.center,
                    child: const Center(
                      child: Icon(
                        Icons.safety_divider_rounded,
                        color: AppConstants.backgroundColor,
                        size: 26,
                      ),
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: LiveStreamTitleAndGoalArea(
                  goal: model,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: model != null
                    ? model!.onMuteUnMute
                    : () {
                        flashFunc;
                        isMicOn = !isMicOn;
                      },
                child: Container(
                  padding: const EdgeInsets.all(11),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: AppConstants.defaultGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: WebsafeSvg.asset(
                      // ignore: dead_code
                      model != null
                          ? !model!.isMic
                              ? micOnIcon
                              : micOffIcon
                          : isMicOn
                              ? micOnIcon
                              : micOffIcon,
                      colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                      height: 25,
                      width: 25,
                      fit: BoxFit.contain),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(child: SizedBox()),
                  InkWell(
                    onTap: model != null ? model!.flipCamera : switchCamFunc!,
                    // () {
                    //     switchCamFunc;
                    //     isFrontCam = !isFrontCam;
                    //   },
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppConstants.defaultGradient,
                      ),
                      alignment: Alignment.center,
                      child: WebsafeSvg.asset(cameraIcon,
                         colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ])),
        const SizedBox(
          height: 5,
        ),
        if (model != null && model!.guestUser != null)
          SizedBox(
              height: 50,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LiveStreamBattleGoalArea(
                        goal: model,
                      ),
                    )
                  ]))
      ],
    );
  }
}
