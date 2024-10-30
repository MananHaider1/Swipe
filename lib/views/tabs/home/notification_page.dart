import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart' as an;
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/date_formater.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/notifications/notifs.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/tabs/bottom_nav_bar_page.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';
import 'package:lamatdating/widgets/Subscriptions/subscription_widget.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({
    super.key,
  });

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    final currentUserRef = ref.watch(currentUserStateProvider);
    final userProf =
        UserProfileModel.fromJson(boxMain.get(HiveConstants.currentUserProf));
    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.when(
      data: (data) {
        // if (data.isEmpty) {
        //   debugPrint('no notifications');
        //   return const Center(child: NoItemFoundWidget());
        // } else {
        debugPrint('notifications: ${data.length}');
        // get all notifications Ids
        final List<String> notificationsIds = [];
        for (var element in data) {
          notificationsIds.add(element.id);
        }
        debugPrint('notificationsIds: $notificationsIds');
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultNumericValue),
                child: CustomAppBar(
                  leading: CustomIconButton(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8),
                      onPressed: ()  {
                        (!Responsive.isDesktop(context)) ?
                        Navigator.pop(context) : ref.invalidate(arrangementProvider);},
                      color: AppConstants.primaryColor,
                      icon: leftArrowSvg),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.notifications.tr(),
                  )),
                  trailing: CustomPopupMenu(
                    menuBuilder: () => ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue / 2),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MoreMenuTitle(
                                title: LocaleKeys.markallasread.tr(),
                                onTap: () async {
                                  _moreMenuController.hideMenu();
                                  await markAllAsRead(
                                      currentUserRef!.phoneNumber!);
                                },
                              ),
                              MoreMenuTitle(
                                title: "delete all notifications",
                                onTap: () async {
                                  _moreMenuController.hideMenu();
                                  await deleteAllNotifications(
                                      notificationsIds);
                                },
                              ),
                              if (!kIsWeb)
                                MoreMenuTitle(
                                  title: "Test Notification",
                                  onTap: () async {
                                    _moreMenuController.hideMenu();
                                    an.AwesomeNotifications()
                                        .createNotification(
                                            content: an.NotificationContent(
                                      id: 10,
                                      channelKey: 'lamat',
                                      bigPicture:
                                          "https://images.pexels.com/photos/7480127/pexels-photo-7480127.jpeg?cs=srgb&dl=pexels-angela-roma-7480127.jpg&fm=jpg",
                                      actionType: an.ActionType.Default,
                                      title: 'Hello World!',
                                      body: 'This is my test notification!',
                                    ));
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    pressType: PressType.singleClick,
                    verticalMargin: 0,
                    controller: _moreMenuController,
                    showArrow: true,
                    arrowColor: Colors.white,
                    barrierColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: GestureDetector(
                      child: const Icon(CupertinoIcons.ellipsis_vertical),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              ListTile(
                onTap: () {
                  Navigator.push(
                      this.context,
                      MaterialPageRoute(
                          builder: (context) => AllNotifications(
                                prefs: prefs!,
                              )));
                },
                contentPadding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultNumericValue,
                    3,
                    AppConstants.defaultNumericValue,
                    3),
                trailing: const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.notifications_none,
                    color: AppConstants.primaryColor,
                    size: 29,
                  ),
                ),
                title: Text(LocaleKeys.promotionalEventsAlerts.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    )),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              if (prefs != null)
                Expanded(
                    child: NotificationBody(
                        prefs: prefs, data: data, user: userProf))
              else
                const Center(
                  child: NoItemFoundWidget(),
                ),
            ],
          ),
        );
      },
      error: (e, st) {
        debugPrint("Error CODE ==> $e");
        debugPrint("StackTrace ===> $st");
        return ErrorPage(title: "$e");
      },
      loading: () {
        return const NoItemFoundWidget();
      },
    );
  }
}

class NotificationBody extends ConsumerWidget {
  final SharedPreferences prefs;
  final List<NotificationModel> data;
  final UserProfileModel user;

  const NotificationBody({
    super.key,
    required this.prefs,
    required this.data,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final UserProfileModel? user = ref.watch(userProfileFutureProvider).value;

    void deleteNotificationDialog(NotificationModel item) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.areyousureyouwanttodeletethisnotification
                      .tr()),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(
                          LocaleKeys.cancel.tr(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: AppConstants.defaultNumericValue),
                      TextButton(
                        child: Text(LocaleKeys.delete.tr()),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteNotification(item.phoneNumber!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
    }

    void onTapNotification(WidgetRef ref, NotificationModel item) {
      if (item.isMatchingNotification) {
        final otherUsers = ref.watch(otherUsersProvider(ref));

        UserProfileModel? otherUser;
        otherUsers.whenData((value) {
          otherUser = value.firstWhere(
              (element) => element.phoneNumber == item.phoneNumber!);
        });

        if (otherUser != null) {
          if (!item.isRead) {
            updateNotification(item.copyWith(isRead: true));
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(
                user: otherUser!,
                matchId: item.matchId,
              ),
            ),
          );
        }
      }

      if (item.isInteractionNotification) {
        if (!item.isRead) {
          updateNotification(item.copyWith(isRead: true));
        }
        showDialog(
            context: context,
            builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Teme.isDarktheme(prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: !Responsive.isDesktop(context) ? MediaQuery.of(context).size.width * .8 : MediaQuery.of(context).size.width * .25,
                  height: !Responsive.isDesktop(context) ? MediaQuery.of(context).size.width *1.1 : MediaQuery.of(context).size.height * .7,
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(item.image!),
                      ),
                      const SizedBox(height: AppConstants.defaultNumericValue),
                      Text(item.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppConstants.defaultNumericValue),
                      Text(item.body,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppConstants.defaultNumericValue),
                      // Text(item.!, style: Theme.of(context).textTheme.bodyMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: Text(
                              LocaleKeys.close.tr(),
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                          TextButton(
                            child: Text(LocaleKeys.delete.tr()),
                            onPressed: () {
                              Navigator.pop(context);
                              deleteNotification(item.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
      }
    }

    return SubscriptionBuilder(builder: (context, isPremiumUser) {
      return ListView.separated(
        itemBuilder: (context, index) {
          NotificationModel item = data[index];

          return SizedBox(
            height: 95,
            child: Stack(children: [
              ListTile(
                onLongPress: () {
                  deleteNotificationDialog(item);
                },
                onTap: () {
                  onTapNotification(ref, item);
                },
                minTileHeight: 95,
                title: Text(item.title),
                tileColor: item.isRead
                    ? null
                    : AppConstants.primaryColor.withOpacity(0.2),
                subtitle: Text(item.body),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.toTime(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      DateFormatter.toYearMonthDay2(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                leading: item.image == null
                    ? CircleAvatar(
                        radius: AppConstants.defaultNumericValue * 2,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          item.title.substring(0, 1),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        ),
                      )
                    : UserCirlePicture(
                        imageUrl: item.image,
                        size: AppConstants.defaultNumericValue * 2),
              ),
              // Blurred background container
              if ((!isPremiumUser || !user.isPremium!) &&
                  item.isInteractionNotification)
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        
                        builder: (context) => const SubscriptionWidget());
                  },
                  child: ClipRect(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            width: double.infinity,
                            height: 95.0,
                            color: AppConstants.primaryColor.withOpacity(
                                0.5), // Adjust color and opacity for desired blur effect
                          ))),
                ),
            ]),
          );
        },
        itemCount: data.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
      );
    });
  }
}
