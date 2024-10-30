import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/modal/battle/battle_live.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/responsive.dart';
// import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/home/user_card_widget.dart';

class UserImageCard extends ConsumerWidget {
  final String? matchId;
  final UserProfileModel user;
  final bool? isInvite;
  final String? channelId;
  final String? inviteePhone;
  final GoalModel? goalModel;
  final bool? isHost;
  final bool? isCoHost;
  final String? status;

  const UserImageCard(
      {super.key,
      this.matchId,
      required this.user,
      this.isInvite,
      this.channelId,
      this.inviteePhone,
      this.goalModel,
      this.isHost,
      this.isCoHost,
      this.status});

  @override
  Widget build(BuildContext context, ref) {
    final prefs = ref.watch(sharedPreferences).value;
    return GestureDetector(
      onTap: () async {
        DataModel? cachedModel;
        cachedModel ??=
            DataModel(ref.watch(currentUserStateProvider)!.phoneNumber);
        !Responsive.isDesktop(context)
            ? !(isInvite != null && isInvite == true)
                ? Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) =>
                            UserDetailsPage(user: user, matchId: matchId)))
                : {
                    EasyLoading.show(),
                    await inviteLiveBattle(
                      channelId: channelId!,
                      inviteePhone: user.phoneNumber,
                      userProf: user,
                      goalModel: goalModel!,
                      isHost: false,
                      isCoHost: true,
                      status: "pending",
                      context: context,
                    ),
                    EasyLoading.dismiss(),
                    EasyLoading.showSuccess(LocaleKeys.sentSuccessfully.tr()),
                  }
            : (isInvite != null && isInvite == true)
                ? {
                    EasyLoading.show(),
                    await inviteLiveBattle(
                      channelId: channelId!,
                      inviteePhone: user.phoneNumber,
                      goalModel: goalModel!,
                      isHost: false,
                      isCoHost: true,
                      status: "pending",
                      context: context,
                    ),
                    EasyLoading.dismiss(),
                    EasyLoading.showSuccess(LocaleKeys.sentSuccessfully.tr()),
                  }
                : {
                    updateCurrentIndex(ref, 10),
                    ref
                        .read(arrangementProvider.notifier)
                        .setArrangement(UserDetailsPage(
                          user: user,
                        )),
                    ref.read(arrangementProviderExtend.notifier).setArrangement(
                          PreChat(
                            name: user.fullName,
                            phone: user.phoneNumber,
                            currentUserNo: ref
                                .watch(currentUserStateProvider)!
                                .phoneNumber,
                            model: cachedModel,
                            prefs: prefs!,
                          ),
                        )
                  };
      },
      child: GridTile(
        footer: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultNumericValue / 2,
            horizontal: AppConstants.defaultNumericValue,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(AppConstants.defaultNumericValue / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue / 2),
                  color: Colors.black38,
                ),
                child: Center(
                  child: Text(
                    '${user.fullName.split(" ").first} ${DateTime.now().difference(user.birthDay).inDays ~/ 365}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (matchId != null)
                const Icon(CupertinoIcons.heart_solid,
                    color: CupertinoColors.destructiveRed,
                    size: AppConstants.defaultNumericValue * 1.5),
              const Spacer(),
              if (user.isVerified)
                GestureDetector(
                  onTap: () {
                    EasyLoading.showToast(LocaleKeys.verifiedUser.tr());
                  },
                  child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultNumericValue),
                      child: Image(
                        image: AssetImage(verifiedIcon),
                        height: 22,
                        width: 22,
                      )),
                ),
              if (user.isOnline) const SizedBox(width: 4),
              if (user.isOnline) const OnlineStatus(),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
            child: (user.mediaFiles.isEmpty && user.profilePicture == null)
                ? const Center(
                    child: Icon(CupertinoIcons.photo),
                  )
                : (user.profilePicture != null)
                    ? CachedNetworkImage(
                        imageUrl: user.profilePicture!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (context, url, error) {
                          return const Center(
                              child: Icon(CupertinoIcons.photo));
                        },
                      )
                    : user.mediaFiles.isEmpty
                        ? const Center(
                            child: Icon(CupertinoIcons.photo),
                          )
                        : CachedNetworkImage(
                            imageUrl: user.mediaFiles.isNotEmpty
                                ? user.mediaFiles.first
                                : '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator.adaptive()),
                            errorWidget: (context, url, error) {
                              return const Center(
                                  child: Icon(CupertinoIcons.photo));
                            },
                          ),
          ),
        ),
      ),
    );
  }
}

class GroupImageCard extends ConsumerStatefulWidget {
  final String? matchId;
  final GroupModel user;

  const GroupImageCard({
    super.key,
    this.matchId,
    required this.user,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupImageCardState();
}

class _GroupImageCardState extends ConsumerState<GroupImageCard> {
  bool isFollow = false;
  @override
  Widget build(BuildContext context) {
    final currentUserNo = ref.watch(currentUserStateProvider)!.phoneNumber;
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //         builder: (context) =>
        //             UserDetailsPage(user: user, matchId: matchId)));
      },
      child: GridTile(
        footer: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultNumericValue / 2,
            horizontal: AppConstants.defaultNumericValue,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(AppConstants.defaultNumericValue / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue / 2),
                  color: Colors.black38,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        '${widget.user.docmap[Dbkeys.groupNAME]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (widget.user.docmap[Dbkeys.groupISVERIFIED])
                        GestureDetector(
                          onTap: () {
                            EasyLoading.showToast(LocaleKeys.verifiedUser.tr());
                          },
                          child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.defaultNumericValue),
                              child: Image(
                                image: AssetImage(verifiedIcon),
                                height: 22,
                                width: 22,
                              )),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Switch.adaptive(),
              CircleAvatar(
                radius: AppConstants.defaultNumericValue * 1.2,
                backgroundColor: AppConstants.primaryColor.withOpacity(.5),
                child: InkWell(
                  onTap: () async {
                    await FirebaseGroupServices()
                        .addUserToGroup(
                            widget.user.docmap[Dbkeys.groupID], currentUserNo)
                        .then((value) {
                      value == true
                          ? {isFollow = !isFollow}
                          : {isFollow = isFollow};
                    });
                    setState(() {});
                  },
                  child: Icon(
                      (isFollow == false)
                          ? CupertinoIcons.add_circled
                          : CupertinoIcons.check_mark_circled_solid,
                      color: Colors.white,
                      size: AppConstants.defaultNumericValue * 2),
                ),
              ),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
            child: (widget.user.docmap[Dbkeys.groupPHOTOURL].isEmpty &&
                    widget.user.docmap[Dbkeys.groupPHOTOURL] == null)
                ? const Center(
                    child: Icon(CupertinoIcons.photo),
                  )
                : (widget.user.docmap[Dbkeys.groupPHOTOURL] != null)
                    ? CachedNetworkImage(
                        imageUrl: widget.user.docmap[Dbkeys.groupPHOTOURL]!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (context, url, error) {
                          return const Center(
                              child: Icon(CupertinoIcons.photo));
                        },
                      )
                    : widget.user.docmap[Dbkeys.groupPHOTOURL].isEmpty
                        ? const Center(
                            child: Icon(CupertinoIcons.photo),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.user.docmap[Dbkeys.groupPHOTOURL]
                                    .isNotEmpty
                                ? widget.user.docmap[Dbkeys.groupPHOTOURL]
                                : '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator.adaptive()),
                            errorWidget: (context, url, error) {
                              return const Center(
                                  child: Icon(CupertinoIcons.photo));
                            },
                          ),
          ),
        ),
      ),
    );
  }
}
