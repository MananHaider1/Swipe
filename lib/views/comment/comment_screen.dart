// ignore_for_file: library_private_types_in_public_api, unused_local_variable, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/models/feed_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/comment_model.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/feed_provider.dart' as feed;
import 'package:lamatdating/providers/user_profile_provider.dart';

import 'package:lamatdating/helpers/my_loading/costumview/common_ui.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final TeelsModel? videoData;
  final FeedModel? feedData;
  final Function onComment;

  const CommentScreen(this.videoData, this.onComment, this.feedData,
      {super.key});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  int start = 0;

  bool isLoading = true;
  final TextEditingController _editingController = TextEditingController();
  String commentText = '';

  @override
  void initState() {
    super.initState();
  }

  comentAge(DateTime commentTime) {
    final now = DateTime.now();
    final difference = now.difference(commentTime);

    // Calculate minutes and hours
    final minutes = difference.inMinutes;
    final hours = difference.inHours;

    // Check if older than 24 hours
    if (difference.inDays >= 1) {
      return DateFormat('dd/MM/yyyy').format(commentTime); // Show date
    } else if (hours > 0) {
      return '${hours}h'; // Show hours
    } else {
      return '${minutes}m'; // Show minutes
    }
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // final commentsList = commentsProvider;
    final currentUserId =
        ref.watch(currentUserStateProvider)!.phoneNumber.toString();
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.defaultNumericValue),
        ),
        color: Teme.isDarktheme(prefs!)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
      ),
      constraints: BoxConstraints(
        maxHeight: height,
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              color: Teme.isDarktheme(prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
            ),
            child: Stack(
              children: [
                Center(
                  child: widget.videoData != null
                      ? Text(
                          '${widget.videoData!.comments.length.toString()} ${'comments'.tr()}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          '${widget.feedData!.comments.length.toString()} ${'comments'.tr()}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    onTap: () {
                      !(Responsive.isDesktop(context))
                          ? Navigator.pop(context)
                          : ref.invalidate(arrangementProvider);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: WebsafeSvg.asset(
                        height: 36,
                        width: 36,
                        fit: BoxFit.fitHeight,
                        closeIcon,
                      
                             colorFilter:   ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 !Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                   
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.videoData != null
              ? Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final commentsAsyncValue =
                          ref.watch(commentsProvider(widget.videoData!.id));
                      final otherUsersAsyncValue =
                          ref.watch(otherUsersProvider(ref));
                      final currentUserProfileAsyncValue =
                          ref.watch(userProfileFutureProvider);

                      return currentUserProfileAsyncValue.when(
                        data: (currentUserProfile) {
                          return otherUsersAsyncValue.when(
                            data: (otherUsers) {
                              // Create a map of userIds to user profiles
                              final userIdToProfile = {
                                for (var user in otherUsers)
                                  user.phoneNumber: user
                              };

                              // Add the current user's profile to the map
                              userIdToProfile[currentUserProfile!.phoneNumber] =
                                  currentUserProfile;

                              return commentsAsyncValue.when(
                                data: (comments) => ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment =
                                        CommentModel.fromMap(comments[index]);
                                    // Get the user profile for this comment's phoneNumber
                                    final userProfile =
                                        userIdToProfile[comment.phoneNumber];
                                    if (kDebugMode) {
                                      print(comment);
                                    }

                                    return ListTile(
                                        // leading: Column(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.start,
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [

                                        //     ]),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            UserCirlePicture(
                                                imageUrl:
                                                    userProfile?.profilePicture,
                                                size: AppConstants
                                                        .defaultNumericValue *
                                                    2.5),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(AppConstants
                                                            .defaultNumericValue),
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(.1)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userProfile?.fullName ??
                                                          'unknown'.tr(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: AppConstants
                                                              .defaultNumericValue /
                                                          3,
                                                    ),
                                                    Text(
                                                      comment.text,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            const SizedBox(width: 56),
                                            Text(comentAge(comment.createdAt)),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            StreamBuilder<int>(
                                              stream: getTotalLikesComment(
                                                  widget.videoData!.id,
                                                  comment.id),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<int> snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Text("0 ");
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      '${LocaleKeys.error.tr()}: ${snapshot.error}');
                                                } else {
                                                  return Text(
                                                      '${snapshot.data.toString()} ');
                                                }
                                              },
                                            ),
                                            StreamBuilder<bool>(
                                              stream: isLikedComment(
                                                  widget.videoData!.id,
                                                  comment.id,
                                                  ref
                                                      .watch(
                                                          currentUserStateProvider)!
                                                      .phoneNumber!),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<bool>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator()); // Show loading indicator while waiting
                                                } else {
                                                  {
                                                    return InkWell(
                                                        onTap: () async {
                                                          await likeComment(
                                                                  comment.id,
                                                                  widget
                                                                      .videoData!
                                                                      .id,
                                                                  currentUserId)
                                                              .then((value) =>
                                                                  (kDebugMode)
                                                                      ? print(
                                                                          "Liked ==> $value")
                                                                      : {});
                                                        },
                                                        child: WebsafeSvg.asset(
                                                          height: 25,
                                                          width: 25,
                                                          fit: BoxFit.fitHeight,
                                                          (snapshot.data ==
                                                                  true)
                                                              ? likeIcon
                                                              : emptyLikeIcon,
                                                         
                                                                      colorFilter:   ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 (snapshot
                                                                      .data ==
                                                                  true)
                                                              ? Colors.red
                                                              : !Teme.isDarktheme(
                                                                      prefs)
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                 
                                                        ));
                                                  }
                                                }
                                              },
                                            ),
                                            // InkWell(
                                            //   onTap:() {
                                            //     likeComment(comment['id'], widget.videoData!.id, currentUserId );
                                            //   },
                                            //   child: Text("Like")),
                                            // const SizedBox(
                                            //   width: 20,
                                            // ),
                                            // WebsafeSvg.asset(
                                            //   height: 36,
                                            //   width: 36,
                                            //   fit: BoxFit.fitHeight,
                                            //   paperplaneIcon,
                                            //   color: AppConstants.primaryColor,
                                            // ),
                                            // const SizedBox(
                                            //   width: 20,
                                            // ),
                                          ],
                                        ));
                                  },
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (_, __) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final commentsAsyncValue =
                          ref.watch(feed.commentsProvider(widget.feedData!.id));
                      final otherUsersAsyncValue =
                          ref.watch(otherUsersProvider(ref));
                      final currentUserProfileAsyncValue =
                          ref.watch(userProfileFutureProvider);

                      return currentUserProfileAsyncValue.when(
                        data: (currentUserProfile) {
                          return otherUsersAsyncValue.when(
                            data: (otherUsers) {
                              // Create a map of userIds to user profiles
                              final userIdToProfile = {
                                for (var user in otherUsers)
                                  user.phoneNumber: user
                              };

                              // Add the current user's profile to the map
                              userIdToProfile[currentUserProfile!.phoneNumber] =
                                  currentUserProfile;

                              return commentsAsyncValue.when(
                                data: (comments) => ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    CommentModel comment =
                                        CommentModel.fromMap(comments[index]);
                                    if (comment.id == '') {
                                      final updateComment = comment.copyWith(
                                          createdAt: DateTime.now(),
                                          id: feed.userIdDateTime(
                                              comment.phoneNumber));
                                      feed
                                          .updateComment(widget.feedData!.id,
                                              updateComment)
                                          .then((value) => null);
                                    }
                                    // Get the user profile for this comment's phoneNumber
                                    final userProfile =
                                        userIdToProfile[comment.phoneNumber];
                                    if (kDebugMode) {
                                      print(comment);
                                    }

                                    return ListTile(
                                        // leading: Column(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.start,
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [

                                        //     ]),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            UserCirlePicture(
                                                imageUrl:
                                                    userProfile?.profilePicture,
                                                size: AppConstants
                                                        .defaultNumericValue *
                                                    2.5),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(AppConstants
                                                            .defaultNumericValue),
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(.1)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userProfile?.fullName ??
                                                          'unknown'.tr(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: AppConstants
                                                              .defaultNumericValue /
                                                          3,
                                                    ),
                                                    Text(
                                                      comment.text,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            const SizedBox(width: 56),
                                            Text(comentAge(comment.createdAt)),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            StreamBuilder<int>(
                                              stream: feed.getTotalLikesComment(
                                                  widget.feedData!.id,
                                                  comment.id),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<int> snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Text("0 ");
                                                } else if (snapshot.hasError) {
                                                  return const Text("");
                                                } else {
                                                  return Text(
                                                      '${snapshot.data.toString()} ');
                                                }
                                              },
                                            ),
                                            StreamBuilder<bool>(
                                              stream: feed.isLikedComment(
                                                  widget.feedData!.id,
                                                  comment.id,
                                                  ref
                                                      .watch(
                                                          currentUserStateProvider)!
                                                      .phoneNumber!),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<bool>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator()); // Show loading indicator while waiting
                                                } else {
                                                  {
                                                    return InkWell(
                                                        onTap: () async {
                                                          await feed
                                                              .likeComment(
                                                                  comment.id,
                                                                  widget
                                                                      .feedData!
                                                                      .id,
                                                                  currentUserId)
                                                              .then((value) =>
                                                                  (kDebugMode)
                                                                      ? print(
                                                                          "Liked ==> $value")
                                                                      : {});
                                                        },
                                                        child: WebsafeSvg.asset(
                                                          height: 25,
                                                          width: 25,
                                                          fit: BoxFit.fitHeight,
                                                          (snapshot.data ==
                                                                  true)
                                                              ? likeIcon
                                                              : emptyLikeIcon,
                                                           
                                                                       colorFilter:   ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 (snapshot
                                                                      .data ==
                                                                  true)
                                                              ? Colors.red
                                                              : !Teme.isDarktheme(
                                                                      prefs)
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                   
                                                        ));
                                                  }
                                                }
                                              },
                                            ),
                                            // InkWell(
                                            //   onTap:() {
                                            //     likeComment(comment['id'], widget.videoData!.id, currentUserId );
                                            //   },
                                            //   child: Text("Like")),
                                            // const SizedBox(
                                            //   width: 20,
                                            // ),
                                            // WebsafeSvg.asset(
                                            //   height: 36,
                                            //   width: 36,
                                            //   fit: BoxFit.fitHeight,
                                            //   paperplaneIcon,
                                            //   color: AppConstants.primaryColor,
                                            // ),
                                            // const SizedBox(
                                            //   width: 20,
                                            // ),
                                          ],
                                        ));
                                  },
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (_, __) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              color: AppConstants.primaryColor.withOpacity(.1),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      commentText = value;
                    },
                    controller: _editingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'leaveYourComment'.tr(),
                      hintStyle: const TextStyle(
                        color: AppConstants.hintColor,
                        fontFamily: fNSfUiRegular,
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: ClipOval(
                    child: InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      onTap: () {
                        if (commentText.isEmpty) {
                          CommonUI.showToast(msg: 'enterCommentFirst'.tr());
                        } else {
                          // EasyLoading.show();
                          if (widget.videoData != null) {
                            addComment(widget.videoData!.id.toString(),
                                commentText, currentUserId);
                          } else {
                            feed.addComment(widget.feedData!.id.toString(),
                                commentText, currentUserId);
                          }

                          start = 0;

                          _editingController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          widget.onComment;
                          EasyLoading.dismiss();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 5, left: 7, right: 8),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: AppConstants.defaultGradient),
                        child: WebsafeSvg.asset(
                          paperplaneIcon,
                          colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserCirlePicture extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  const UserCirlePicture({
    super.key,
    required this.imageUrl,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final newSize = size ?? AppConstants.defaultNumericValue * 5;
    return Container(
      width: newSize,
      height: newSize,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultNumericValue * 10),
        border: Border.all(color: AppConstants.primaryColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultNumericValue * 10),
        child: imageUrl == null || imageUrl!.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: AppConstants.primaryColor,
                  size: newSize * 0.8,
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
