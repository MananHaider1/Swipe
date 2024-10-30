// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_is_empty

import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:stacked/stacked.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/modal/live_stream/live_stream.dart';
import 'package:lamatdating/modal/user/user.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_end_screen.dart';
import 'package:lamatdating/views/tabs/live/widgets/end_dialog.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

class BroadCastScreenViewModel extends BaseViewModel {
  String? channelId;
  String? thumbNail;
  final UserProfileModel userProfile;
  final GoalModel? goalModel;
  final WidgetRef ref;
  final bool isHost;
  final bool isCoHost;

  BroadCastScreenViewModel({
    Key? key,
    this.channelId,
    this.thumbNail,
    this.goalModel,
    required this.userProfile,
    required this.ref,
    required this.isHost,
    required this.isCoHost,
  });
  void init(
      {required bool isBroadCast,
      required bool isCoHost,
      required String agoraToken,
      required String channelName,
      required UserProfileModel? registrationUser,
      UserProfileModel? guestUser,
      required WidgetRef ref,
      required BuildContext context}) {
    // registrationUser?.phoneNumber = channelName;
    AgoraRes.token = agoraToken;
    AgoraRes.channelName = channelName;
    buildContext = context;
    commentList = [];
    this.registrationUser = registrationUser;
    this.guestUser = guestUser;
    channelId = channelName;
    prefData();
    setupVideoSDKEngine(ref);
    rtcEngineHandlerCall(context, ref);
    // if (!kIsWeb) {
    //   CommonFun.interstitialAd((ad) {
    //     interstitialAd = ad;
    //     notifyListeners();
    //   });
    // }
    WakelockPlus.enable();
  }

  String time = '';
  String watching = '';
  String diamond = '';
  String image = '';
  String? diamondGuest;
  String? imageGuest;
  UserProfileModel? registrationUser;
  UserProfileModel? guestUser;
  int uid = 0; // uid of the local user
  int? _remoteUid; // uid of the remote user
  static final _users = <int>[];
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  RtcEngineEventHandler? engineEventHandler;
  bool isMic = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  List<LiveStreamComment> commentList = [];
  // SessionManager pref = SessionManager();
  User? user;
  StreamSubscription<QuerySnapshot<LiveStreamComment>>? commentStream;
  late BuildContext buildContext;
  bool isGiftDialogOpen = false;
  bool isPurchaseDialogOpen = false;
  bool isEndDialogOpen = false;
  bool startStop = true;
  Timer? timer;
  Stopwatch watch = Stopwatch();
  String elapsedTime = '';
  LiveStreamUser? liveStreamUser;
  DateTime? dateTime;
  Timer? minimumUserLiveTimer;
  int countTimer = 0;
  int maxMinutes = SettingRes.liveTimeout!;
  InterstitialAd? interstitialAd;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);
  List<UserProfileModel> hostsList = [];
  bool isEngineInit = false;

  void rtcEngineHandlerCall(BuildContext context, ref) {
    final regisUser = ref.watch(userProfileFutureProvider);
    if (kDebugMode) {
      print("agoraEngine ==> Start Adding user1");
    }
    engineEventHandler = RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      uid = connection.localUid!;
      _isJoined = true;
      if (kDebugMode) {
        print("agoraEngine ==> Start Adding user");
      }
      regisUser.when(data: (data) async {
        if (data != null) {
          EasyLoading.show();
          final regUser = data;
          if (kDebugMode) {
            print(regUser);
          }
          if (isHost) {
            final box = Hive.box(HiveConstants.hiveBox);
            final agoraTokenCached = await box.get(HiveConstants.agoraToken);
            final channelIdCached = await box.get(HiveConstants.agoraChannelId);
            db
                .collection(FirebaseConst.liveStreamUser)
                .doc(regUser?.phoneNumber)
                .set(LiveStreamUser(
                    fullName: regUser?.fullName ?? '',
                    isVerified: regUser?.isVerified,
                    agoraToken: agoraTokenCached,
                    channelId: channelIdCached,
                    collectedDiamond: 0,
                    hostIdentity: registrationUser?.phoneNumber,
                    id: "${regUser?.phoneNumber}-${DateTime.now().millisecondsSinceEpoch.toString()}",
                    joinedUser: [],
                    phoneNumber: regUser?.phoneNumber ?? "",
                    userImage: regUser?.profilePicture ?? '',
                    thumbnail: thumbNail ?? '',
                    userName: regUser?.userName ?? '',
                    watchingCount: 0,
                    followers: regUser?.followersCount,
                    streamTitle: goalModel?.streamTitle,
                    streamGoal: goalModel?.streamGoal,
                    streamGoalType: goalModel?.streamGoalType,
                    goalDescription: goalModel?.goalDescription,
                    battleUsers: []).toJson());
          }
          if (isCoHost) {
            db
                .collection(FirebaseConst.liveStreamUser)
                .doc(liveStreamUser!.phoneNumber)
                .update({
              "battleUsers": FieldValue.arrayUnion([registrationUser!, regUser])
            });
          }
          notifyListeners();
        }
      });
    }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
      _remoteUid = remoteUid;
      if (isCoHost) {
        _users.add(remoteUid);
      }
      notifyListeners();
    }, onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
      audienceExit(context);
      if (isCoHost) {
        _users.remove(remoteUid);
      }
    }, onLeaveChannel: (connection, stats) {
      debugPrint(stats.toString());
    }, onError: (code, error) {
      debugPrint('RtcEngineEventHandler onError ==> $error');
    });
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: VideoCanvas(uid: uid),
      ),
    ));
    for (var uid in _users) {
      list.add(AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid),
          connection: RtcConnection(channelId: channelId),
        ),
      ));
    }
    return list;
  }

  Widget videoPanel(BuildContext context) {
    final views = _getRenderViews();
    if (_isJoined == false) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.pink,
      ));
    } else if (views.length == 1) {
      // Local user joined as a host
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid),
        ),
      );
    } else if (views.length == 2) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Row(
          children: [views[0], views[1]],
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelId),
        ),
      );
    }
  }

  bool _engineInitialized = false;

  Future<void> setupVideoSDKEngine(ref) async {
    // retrieve or request camera and microphone permissions
    // await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();

    if (kDebugMode) {
      print("agoraEngine ==> Initializing");
    }

    await agoraEngine
        .initialize(const RtcEngineContext(appId: AppConstants.agoraAppId));
    isEngineInit = true;
    if (kDebugMode) {
      print("agoraEngine ==> Initialized");
    }

    await agoraEngine.enableVideo();

    if (kDebugMode) {
      print("agoraEngine ==> enabled Video");
    }

    join(ref);
    _engineInitialized = true;
    // Register the event handler
    if (engineEventHandler != null) {
      agoraEngine.registerEventHandler(engineEventHandler!);
    }
  }

  void join(ref) async {
    final AsyncData<UserProfileModel?> regisUser =
        ref.watch(userProfileFutureProvider);
    if (kDebugMode) {
      print("Set channel options");
    }
    // Set channel options
    ChannelMediaOptions options;

    // if (kDebugMode) {
    //   print("Firebase profile: ${registrationUser!.fullName}");
    // }

    // Set channel profile and client role
    if (isHost) {
      startWatch();
      if (kDebugMode) {
        print("agoraEngine ==> Timer Started");
      }
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      if (kDebugMode) {
        print("agoraEngine ==> starting Preview");
      }
      await agoraEngine.startPreview();
      if (kDebugMode) {
        print("agoraEngine ==> started Preview");
      }
    }
    if (isCoHost) {
      startWatch();
      if (kDebugMode) {
        print("agoraEngine ==> Timer Started");
      }
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      if (kDebugMode) {
        print("agoraEngine ==> starting Preview");
      }
      await agoraEngine.startPreview();
      if (kDebugMode) {
        print("agoraEngine ==> started Preview");
      }
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    }

    if (kDebugMode) {
      print("agoraEngine ==> agoraEngine.joinChannel");
    }
    await db
        .collection(FirebaseConstants.userProfileCollection)
        .doc(registrationUser?.phoneNumber)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        registrationUser = UserProfileModel.fromMap(snapshot.data()!);
        if (kDebugMode) {
          print(userProfile);
        }
      }
    });
    final random = Random();
    await agoraEngine.joinChannel(
      token: registrationUser?.agoraToken as String,
      channelId: channelId!,
      options: options,
      uid: isHost ? uid : random.nextInt(999) + 1,
    );
    if (kDebugMode) {
      print(
          "agoraEngine ==> JoinedChannel \ntoken: ${registrationUser?.agoraToken as String} \nchannelId: ${channelId!} \nuid: $uid.toString(),");
    }
    _isJoined = true;
    regisUser.when(
        data: (data) async {
          if (data != null) {
            EasyLoading.show();
            final UserProfileModel regUser = data;
            if (kDebugMode) {
              print(regUser);
            }
            if (isHost) {
              final box = Hive.box(HiveConstants.hiveBox);
              final agoraTokenCached = await box.get(HiveConstants.agoraToken);
              final channelIdCached =
                  await box.get(HiveConstants.agoraChannelId);
              db
                  .collection(FirebaseConst.liveStreamUser)
                  .doc(regUser.phoneNumber)
                  .set(
                    LiveStreamUser(
                        fullName: regUser.fullName,
                        isVerified: regUser.isVerified,
                        agoraToken: agoraTokenCached,
                        channelId: channelIdCached,
                        collectedDiamond: 0,
                        hostIdentity: registrationUser?.phoneNumber,
                        id: "${regUser.phoneNumber}-${DateTime.now().millisecondsSinceEpoch.toString()}",
                        joinedUser: [],
                        phoneNumber: regUser.phoneNumber,
                        userImage: regUser.profilePicture ?? '',
                        thumbnail: thumbNail ?? '',
                        userName: regUser.userName,
                        watchingCount: 0,
                        followers: regUser.followers!.length,
                        streamTitle: goalModel?.streamTitle,
                        streamGoal: goalModel?.streamGoal,
                        streamGoalType: goalModel?.streamGoalType,
                        goalDescription: goalModel?.goalDescription,
                        battleUsers: []).toJson(),
                  );
            } else if (isCoHost) {
              db
                  .collection(FirebaseConst.liveStreamUser)
                  .doc(registrationUser?.phoneNumber)
                  .set(
                    LiveStreamUser(
                      battleUsers: [registrationUser!, regUser],
                    ).toJson(),
                    SetOptions(merge: true),
                  );
            }
            notifyListeners();
            EasyLoading.dismiss();
          }
        },
        error: (Object error, StackTrace stackTrace) {},
        loading: () {});
    notifyListeners();
  }

  void onEndButtonClick(BuildContext context, WidgetRef ref) {
    isEndDialogOpen = true;
    EasyLoading.dismiss();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        EasyLoading.dismiss();
        return EndDialog(
          true,
          onYesBtnClick: () {
            leave(context, ref);
          },
        );
      },
    ).then((value) {
      isEndDialogOpen = false;
    });
  }

  void leave(BuildContext context, WidgetRef ref) async {
    if (!_engineInitialized) {
      !Responsive.isDesktop(context)
          ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const LivestreamEndScreen(
                    diamond: "0",
                    image: "",
                    time: "00:00",
                    watching: "0",
                  );
                },
              ),
            )
          : ref
              .read(arrangementProvider.notifier)
              .setArrangement(const LivestreamEndScreen(
                diamond: "0",
                image: "",
                time: "00:00",
                watching: "0",
              ));
    }
    if (kDebugMode) {
      print("agoraEngine Const ==> agoraEngine.leaveChannel");
    }
    time = elapsedTime;
    watching = "${liveStreamUser?.joinedUser!.length}";
    diamond = "${liveStreamUser?.collectedDiamond ?? 0}";
    image = liveStreamUser?.userImage ?? '';
    diamondGuest = "${liveStreamUser?.collectedDiamondGuest ?? 0}";

    imageGuest = (liveStreamUser?.battleUsers! != null &&
            liveStreamUser?.battleUsers!.length != 0)
        ? liveStreamUser?.battleUsers![1].profilePicture ?? ''
        : '';

    _remoteUid = null;
    if (kDebugMode) {
      print("agoraEngine notifyListeners ==> agoraEngine.leaveChannel");
    }
    notifyListeners();
    // liveStreamData();
    if (kDebugMode) {
      print("agoraEngine ==> agoraEngine.leaveChannel");
    }
    // (_isJoined == true)
    //     ?

    {
      agoraEngine.leaveChannel(
        options: const LeaveChannelOptions(),
      );

      if (isHost && _isJoined) {
        final batch = db.batch();
        var collection = db
            .collection(FirebaseConst.liveStreamUser)
            .doc(registrationUser?.phoneNumber)
            .collection(FirebaseConst.comment);
        var snapshots = await collection.get();
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (kDebugMode) {
          print("agoraEngine ==> Comments Deleted");
        }
        db
            .collection(FirebaseConst.liveStreamUser)
            .doc(registrationUser?.phoneNumber)
            .delete();
        if (kDebugMode) {
          print("agoraEngine ==> liveStreamUser Doc Deleted");
        }
        if (isEndDialogOpen && !Responsive.isDesktop(context)) {
          Navigator.pop(context);
        }
        stopWatch();
        if (kDebugMode) {
          print("agoraEngine ==> TimerStopped");
        }

        !Responsive.isDesktop(context)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LivestreamEndScreen(
                      diamond: diamond,
                      image: image,
                      time: time,
                      watching: watching,
                    );
                  },
                ),
              )
            : ref
                .read(arrangementProvider.notifier)
                .setArrangement(LivestreamEndScreen(
                  diamond: diamond,
                  image: image,
                  time: time,
                  watching: watching,
                ));

        // Navigator.pop(context);
      }
      if (isCoHost && _isJoined) {
        await db
            .collection(FirebaseConst.liveStreamUser)
            .doc(registrationUser?.phoneNumber)
            .set(
              LiveStreamUser(
                battleUsers: [registrationUser!],
              ).toJson(),
              SetOptions(merge: true),
            );

        if (kDebugMode) {
          print("agoraEngine ==> Comments Deleted");
        }

        if (isEndDialogOpen && !Responsive.isDesktop(context)) {
          Navigator.pop(context);
        }
        stopWatch();
        if (kDebugMode) {
          print("agoraEngine ==> TimerStopped");
        }
        if (interstitialAd != null) {
          interstitialAd?.show().then((value) {
            Navigator.pop(context);
            !Responsive.isDesktop(context)
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LivestreamEndScreen(
                          diamond: diamondGuest ?? "",
                          image: imageGuest ?? "",
                          time: time,
                          watching: watching,
                        );
                      },
                    ),
                  )
                : ref
                    .read(arrangementProvider.notifier)
                    .setArrangement(LivestreamEndScreen(
                      diamond: diamondGuest ?? "",
                      image: imageGuest ?? "",
                      time: time,
                      watching: watching,
                    ));
          });
        } else {
          !Responsive.isDesktop(context)
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LivestreamEndScreen(
                        diamond: diamondGuest ?? "",
                        image: imageGuest ?? "",
                        time: time,
                        watching: watching,
                      );
                    },
                  ),
                )
              : ref
                  .read(arrangementProvider.notifier)
                  .setArrangement(LivestreamEndScreen(
                    diamond: diamondGuest ?? "",
                    image: imageGuest ?? "",
                    time: time,
                    watching: watching,
                  ));
        }
      }
    }
    // : Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return LivestreamEndScreen(
    //           diamond: diamond,
    //           image: image,
    //           time: time,
    //           watching: watching,
    //         );
    //       },
    //     ),
    //   );
    if (isHost && !_isJoined) {
      !Responsive.isDesktop(context)
          ? Navigator.pop(context)
          : {ref.invalidate(arrangementProvider), Navigator.pop(context)};
    }
    _isJoined = false;
  }

  void prefData() async {
    // await pref.initPref();
    // user = pref.getUser();
    initFirebase();
    // getProfile();
  }

  void initFirebase() async {
    if (kDebugMode) {
      print("Firebase phoneNumber ==> ${registrationUser?.phoneNumber}");
    }

    db
        .collection(FirebaseConst.liveStreamUser)
        .doc(registrationUser?.phoneNumber)
        .withConverter(
          fromFirestore: LiveStreamUser.fromFireStore,
          toFirestore: (LiveStreamUser value, options) => value.toFireStore(),
        )
        .snapshots()
        .listen((event) {
      liveStreamUser = event.data();
      if (kDebugMode) {
        print("LiveStreamUser ==> $liveStreamUser");
      }
      if (isHost) {
        minimumUserLiveTimer ??=
            Timer.periodic(const Duration(seconds: 1), (timer) {
          countTimer++;
          if (countTimer == maxMinutes &&
              liveStreamUser!.watchingCount! <=
                  (SettingRes.liveMinViewers ?? -1)) {
            timer.cancel();
            leave(buildContext, ref);
          }
          if (countTimer == maxMinutes) {
            countTimer = 0;
          }
        });
        notifyListeners();
      }
      notifyListeners();
    });
    commentStream = db
        .collection(FirebaseConst.liveStreamUser)
        .doc(registrationUser?.phoneNumber)
        .collection(FirebaseConst.comment)
        .orderBy(FirebaseConst.id, descending: true)
        .withConverter(
          fromFirestore: LiveStreamComment.fromFireStore,
          toFirestore: (LiveStreamComment value, options) {
            return value.toFireStore();
          },
        )
        .snapshots()
        .listen((event) {
      commentList = [];
      for (int i = 0; i < event.docs.length; i++) {
        commentList.add(event.docs[i].data());
      }
      notifyListeners();
    });
    if (kDebugMode) {
      print("Firebase ==> Initiated");
    }
  }

  onComment() {
    if (commentController.text.isEmpty) {
      return;
    }
    onCommentSend(
        commentType: FirebaseConst.msg, msg: commentController.text.trim());
    commentController.clear();
    commentFocus.unfocus();
  }

  Future<void> onCommentSend({
    required String commentType,
    required String msg,
  }) async {
    //      final currentUser = ref.watch(currentUserStateProvider)!;
    // final UserProfileModel? user =
    //     ref.watch(userProfileFutureProvider).when(data: (data) {
    //   if (data != null) {
    //     registrationUser = data;

    //     return registrationUser;
    //   }
    //   return "";
    // }, error: (Object error, StackTrace stackTrace) {
    //   return "";
    // }, loading: () {
    //   return "";
    // });
    await db
        .collection(FirebaseConst.liveStreamUser)
        .doc(registrationUser?.phoneNumber)
        .collection(FirebaseConst.comment)
        .add(LiveStreamComment(
                id: DateTime.now().millisecondsSinceEpoch,
                userName: userProfile.userName,
                userImage: userProfile.profilePicture ?? '',
                phoneNumber: userProfile.phoneNumber,
                fullName: userProfile.fullName,
                comment: msg,
                commentType: commentType,
                isVerify: userProfile.isVerified)
            .toJson());
  }

  void flipCamera() {
    agoraEngine.switchCamera();
  }

  void onMuteUnMute() {
    isMic = !isMic;
    notifyListeners();
    agoraEngine.muteLocalAudioStream(isMic);
  }

  void audienceExit(BuildContext context) async {
    _remoteUid = null;
    db
        .collection(FirebaseConst.liveStreamUser)
        .doc(registrationUser?.phoneNumber)
        .update(
      {
        FirebaseConst.watchingCount:
            liveStreamUser != null && liveStreamUser?.watchingCount != 0
                ? liveStreamUser!.watchingCount! - 1
                : 0
      },
    );
    Navigator.pop(context);
    agoraEngine.leaveChannel();
    if (isEndDialogOpen) {
      Navigator.pop(context);
    }
    if (isGiftDialogOpen) {
      Navigator.pop(context);
    }
    if (isPurchaseDialogOpen) {
      Navigator.pop(context);
    }
    if (interstitialAd != null) {
      interstitialAd?.show();
      Navigator.pop(context);
    } else {
      // Navigator.pop(context);
    }
  }

  void onGiftTap(BuildContext context, ref, {int? userId}) async {
    // getProfile();

    isGiftDialogOpen = true;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GiftSheet(
            onAddDymondsTap: onAddDymondsTap,
            onGiftSend: (gifts) async {
              EasyLoading.show();
              int value = gifts!.coinPrice!;

              // sendGiftProvider({
              //   'giftCost': '${gifts.coinPrice}',
              //   'recipientId': '${liveStreamUser?.phoneNumber}'
              // });
              final wallet =
                  await walletsCollection.doc(userProfile.phoneNumber).get();
              final senderWalletDoc = WalletsModel.fromMap(wallet.data()!);

              (senderWalletDoc.balance >= double.parse(value.toString()))
                  ? {
                      await sendGiftProvider(
                        giftCost: value,
                        recipientId: userId == null
                            ? '${liveStreamUser?.phoneNumber}'
                            : userId == 0
                                ? liveStreamUser!.battleUsers![0].phoneNumber
                                : liveStreamUser!.battleUsers![1].phoneNumber,
                      ),
                      await db
                          .collection(FirebaseConst.liveStreamUser)
                          .doc(registrationUser?.phoneNumber)
                          .update({
                        FirebaseConst.collectedDiamond:
                            FieldValue.increment(value)
                      }),
                      await onCommentSend(
                          commentType: FirebaseConst.image,
                          msg: gifts.image ?? '')
                    }
                  : {EasyLoading.showError('Insufficient Balance')};
              EasyLoading.dismiss();
              Navigator.pop(context);
            });
      },
    ).then((value) {
      // isGiftDialogOpen = false;
    });
  }

  void onAddDymondsTap(BuildContext context) {
    isPurchaseDialogOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const DialogCoinsPlan();
      },
    ).then((value) {
      isPurchaseDialogOpen = false;
    });
  }

  // void getProfile() async {
  //   await ApiService()
  //       .getProfile(SessionManager.phoneNumber.toString())
  //       .then((value) {
  //     user = value;
  //     notifyListeners();
  //   });
  // }

  void onUserTap(BuildContext context, UserProfileModel hostUser) async {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: UserDetailsPage(
              user: hostUser,
              isStreaming: true,
              onBackFunc: () {
                Navigator.pop(context);
              })),
    );
  }

  void startWatch() {
    startStop = false;
    watch.start();
    timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
    dateTime = DateTime.now();
    notifyListeners();
  }

  updateTime(Timer timer) {
    if (watch.isRunning) {
      elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      notifyListeners();
    }
  }

  void stopWatch() {
    startStop = true;
    watch.stop();
    setTime();
    notifyListeners();
  }

  void setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    elapsedTime = transformMilliSeconds(timeSoFar);
    notifyListeners();
  }

  String transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  // Future<void> liveStreamData() async {
  //   pref.saveString(FirebaseConst.timing, elapsedTime);
  //   pref.saveString(
  //       FirebaseConst.watching, "${liveStreamUser?.joinedUser?.length}");
  //   pref.saveString(
  //       FirebaseConst.collected, "${liveStreamUser?.collectedDiamond}");
  //   pref.saveString(FirebaseConst.profileImage, "${liveStreamUser?.userImage}");
  // }

  @override
  void dispose() {
    commentController.dispose();
    commentStream?.cancel();
    agoraEngine.unregisterEventHandler(engineEventHandler!);
    WakelockPlus.disable();
    timer?.cancel();
    minimumUserLiveTimer?.cancel();
    super.dispose();
  }
}
