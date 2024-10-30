// ignore_for_file: avoid_unnecessary_containers

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/views/tabs/live/screen/broad_cast_screen.dart';
import 'package:lamatdating/views/report/report_page.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/modal/live_stream/live_stream.dart';
import 'package:lamatdating/models/broad_cast_screen_view_model.dart';
import 'package:lamatdating/views/tabs/live/widgets/blur_tab.dart';

class AudienceTopBar extends StatelessWidget {
  final BroadCastScreenViewModel model;
  final LiveStreamUser user;
  final UserProfileModel userProf;

  const AudienceTopBar(
      {super.key,
      required this.model,
      required this.user,
      required this.userProf});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          BlurTab(
            height: 65,
            radius: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      model.onUserTap(context, userProf);
                    },
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: ClipOval(
                        child: user.userImage == null || user.userImage!.isEmpty
                            ? Image.asset(
                                icUserPlaceHolder,
                                fit: BoxFit.cover,
                                color: Colors.grey,
                              )
                            : Image.network(
                                "${user.userImage}",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: fNSfUiMedium),
                              ),
                              Visibility(
                                visible: user.isVerified ?? false,
                                child: GestureDetector(
                                  onTap: () {
                                    EasyLoading.showToast(
                                        LocaleKeys.verifiedUser.tr());
                                  },
                                  child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              AppConstants.defaultNumericValue),
                                      child: Image(
                                        image: AssetImage(verifiedIcon),
                                        height: 22,
                                        width: 22,
                                      )),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${user.followers ?? 0} ${LocaleKeys.followers.tr()}",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: fNSfUiMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => ReportPage(
                            userProfileModel: userProf,
                            onBackFunc: () {
                              Navigator.pop(context);
                            }),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    child: WebsafeSvg.asset(
                      menuIcon,
                      height: 20,
                      width: 20,
                      // color: Colors.white,
                      colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          BlurTab(
            height: 40,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                AppRes.appLogo != null
                    ? Image.network(
                        AppRes.appLogo!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        icLogo,
                        height: 20,
                      ),
                const Spacer(),
                Text(
                  "${NumberFormat.compact(locale: 'en').format(double.parse('${model.liveStreamUser?.watchingCount ?? '0'}'))} Viewers",
                  style: const TextStyle(
                      fontFamily: fNSfUiRegular,
                      fontSize: 15,
                      color: Colors.white),
                ),
                const Spacer(),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    model.audienceExit(context);
                  },
                  child: Row(
                    children: [
                      WebsafeSvg.asset(
                        logoutIcon,
                        height: 20,
                        width: 20,
                       colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          LiveStreamTitleAndGoalArea(
            goal: model,
          ),
          if (model.liveStreamUser!.battleUsers!.length == 2)
            LiveStreamBattleGoalArea(
              goal: model,
            )
        ],
      ),
    );
  }
}
