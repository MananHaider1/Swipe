import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/video/video_list_screen.dart';

class ItemSearchVideo extends ConsumerWidget {
  final TeelsModel? videoData;
  final List<TeelsModel?>? postList;
  final String? type;
  final String? hashTag;
  final String? keyWord;

  const ItemSearchVideo({
    super.key,
    this.videoData,
    this.postList,
    this.type,
    this.hashTag,
    this.keyWord,
  });

  @override
  Widget build(BuildContext context, ref) {
    // final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final UserProfileModel? otherUserProfRef = otherUsers.when(
      data: (users) {
        final userProfile = users.firstWhere(
          (otherUser) =>
              videoData!.phoneNumber.toString() == otherUser.phoneNumber,
          // orElse: () => null,
        );
        return userProfile;
      },
      loading: () {
        return null;

        // Handle loading state
      },
      error: (e, _) {
        return null;

        // Handle error state
      }, // Replace with your error widget
    );
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoListScreen(
            list: postList,
            index: postList!.indexOf(videoData),
            type: type,
            hashTag: hashTag,
            keyWord: keyWord,
          ),
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: AppConstants.backgroundColor,
            ),
            margin: const EdgeInsets.only(top: 10, right: 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Container(
                color: AppConstants.backgroundColorDark,
                child: Image(
                  image: NetworkImage(
                    videoData!.thumbnail!,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 5,
            left: 5,
            bottom: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Image(
                              image: AssetImage(icUserPlaceHolder),
                              color: AppConstants.hintColor,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: ClipOval(
                              child: Image.network(
                                otherUserProfRef!.profilePicture!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        videoData!.singer!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: fNSfUiSemiBold,
                          letterSpacing: 0.6,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  videoData!.caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: fNSfUiLight,
                    letterSpacing: 0.6,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      videoData!.likes.length.toString(),
                      style: const TextStyle(
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            color: Colors.black,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
