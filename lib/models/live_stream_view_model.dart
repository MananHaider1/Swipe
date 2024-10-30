// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:stacked/stacked.dart';

import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/livestream_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/modal/live_stream/live_stream.dart';
import 'package:lamatdating/helpers/common_fun.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/tabs/live/screen/audience_screen.dart';
import 'package:lamatdating/views/tabs/live/screen/broad_cast_screen.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_end_sheet.dart';

class LiveStreamScreenViewModel extends BaseViewModel {
  // SessionManager pref = SessionManager();
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<LiveStreamUser> liveUsers = [];
  StreamSubscription<QuerySnapshot<LiveStreamUser>>? userStream;
  List<String> joinedUser = [];
  UserProfileModel? registrationUser;
  BannerAd? bannerAd;

  void init() {
    if (!kIsWeb) {
      getBannerAd();
    }
    getLiveStreamUser();
  }

  void goLiveTap(BuildContext context, ref) async {
    final currentUser = ref.watch(currentUserStateProvider)!;
    final UserProfileModel? user =
        ref.watch(userProfileFutureProvider).when(data: (data) {
      if (data != null) {
        registrationUser = data;

        return registrationUser;
      }
      return "";
    }, error: (Object error, StackTrace stackTrace) {
      return "";
    }, loading: () {
      return "";
    });
    EasyLoading.show();
    // showDialog(
    //   context: context,
    //   builder: (c) {
    //     return const Center(
    //       child: CircularProgressIndicator(
    //         color: AppConstants.secondaryColor,
    //       ),
    //     );
    //   },
    // );
    await LiveStream()
        .generateAgoraToken(currentUser.phoneNumber, currentUser.phoneNumber)
        .then(
      (value) async {
        await ref.read(userProfileNotifier).updateAgoraToken(
            agoraToken: value.token, phoneNumber: currentUser.phoneNumber);
        final UserProfileModel userNew = user!.copyWith(
          agoraToken: value.token,
        );

        EasyLoading.dismiss();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => BroadCastScreen(
                isHost: true,
                registrationUser: userNew,
                agoraToken: value.token,
                channelId: value.channelId,
                channelName: currentUser.phoneNumber),
          ),
        );
      },
    );
  }

  void getLiveStreamUser() {
    userStream = db
        .collection(FirebaseConst.liveStreamUser)
        .withConverter(
          fromFirestore: LiveStreamUser.fromFireStore,
          toFirestore: (LiveStreamUser value, options) {
            return value.toFireStore();
          },
        )
        .snapshots()
        .listen((event) {
      liveUsers = [];
      for (int i = 0; i < event.docs.length; i++) {
        liveUsers.add(event.docs[i].data());
      }
      debugPrint("liveStreamUsers: ${liveUsers.length}");
      notifyListeners();
    });
  }

  void onImageTap(
      BuildContext context, LiveStreamUser user, WidgetRef ref) async {
    var docRef = FirebaseFirestore.instance
        .collection(FirebaseConst.liveStreamUser)
        .doc(user.hostIdentity);

    docRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        joinedUser.add(registrationUser?.phoneNumber ?? '');
        db
            .collection(FirebaseConst.liveStreamUser)
            .doc(user.hostIdentity)
            .update({
          FirebaseConst.watchingCount: user.watchingCount! + 1,
          FirebaseConst.joinedUser: FieldValue.arrayUnion(joinedUser),
        }).then((value) {
          !Responsive.isDesktop(context)
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudienceScreen(
                      channelName: user.channelId,
                      agoraToken: user.agoraToken,
                      user: user,
                    ),
                  ),
                )
              : ref
                  .read(arrangementProvider.notifier)
                  .setArrangement(AudienceScreen(
                    channelName: user.channelId,
                    agoraToken: user.agoraToken,
                    user: user,
                  ));
        });
      } else {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (c) {
            return LiveStreamEndSheet(
              name: user.fullName ?? '',
              onExitBtn: () async {
                Navigator.pop(context);
                db
                    .collection(FirebaseConst.liveStreamUser)
                    .doc(user.hostIdentity)
                    .delete();
                final batch = db.batch();
                var collection = db
                    .collection(FirebaseConst.liveStreamUser)
                    .doc(user.hostIdentity)
                    .collection(FirebaseConst.comment);
                var snapshots = await collection.get();
                for (var doc in snapshots.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();
              },
            );
          },
        );
      }
    });
  }

  void getBannerAd() {
    CommonFun.bannerAd((ad) {
      bannerAd = ad as BannerAd;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    userStream?.cancel();
    super.dispose();
  }
}
