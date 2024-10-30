// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';

class ItemFollowing extends ConsumerWidget {
  final TeelsModel data;

  const ItemFollowing(this.data, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    // final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;
    final otherUsers = ref.watch(otherUsersProvider(ref));
    UserProfileModel? userProfile;
    final UserProfileModel? otherUserProfRef = otherUsers.when(
      data: (users) {
        userProfile = users.firstWhere(
          (otherUser) => data.phoneNumber.toString() == otherUser.phoneNumber,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      margin: const EdgeInsets.only(bottom: 50, left: 10, right: 10),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: _ButterFlyAssetVideo(data.postVideo!),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(2),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Image(
                              image: AssetImage(icUserPlaceHolder),
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: 40,
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
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.singer!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: fNSfUiSemiBold,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '${AppRes.atSign}${data.userName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              fontFamily: fNSfUiLight,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(0),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserDetailsPage(user: userProfile!),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.secondaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.follow.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: fNSfUiSemiBold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  final String url;

  const _ButterFlyAssetVideo(this.url);

  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.url,
      // isCached: Platform.isAndroid,
    );
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.initialize().then((_) => setState(() {}));
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            onTap: () {},
            child: Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller?.value.size.width ?? 0,
                    height: _controller?.value.size.height ?? 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Center(
                          child: VisibilityDetector(
                            onVisibilityChanged: (VisibilityInfo info) {
                              var visiblePercentage =
                                  info.visibleFraction * 100;
                              if (visiblePercentage > 50) {
                                _controller?.play();
                              } else {
                                _controller?.pause();
                              }
                            },
                            key: Key('ke1${widget.url}'),
                            child: VideoPlayer(
                              _controller!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
