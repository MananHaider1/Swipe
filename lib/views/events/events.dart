import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/events_provider.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/events/events_swipe.dart';
import 'package:lamatdating/views/settings/verification/verification_steps.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsPage extends ConsumerWidget {
  final SharedPreferences prefs;
  EventsPage({super.key, required this.prefs});
  final List<Map<String, dynamic>> vibeCards = [
    {
      'title': 'Looking\nfor Love',
      'imagePath':
          'https://images.pexels.com/photos/1759823/pexels-photo-1759823.jpeg?cs=srgb&dl=pexels-gabriel-bastelli-865174-1759823.jpg&fm=jpg',
      'count': 326
    },
    {
      'title': 'Free\nTonight',
      'imagePath':
          'https://images.pexels.com/photos/801863/pexels-photo-801863.jpeg?cs=srgb&dl=pexels-maumascaro-801863.jpg&fm=jpg',
      'count': 192
    },
    {
      'title': "Let's be\nFriends",
      'imagePath':
          'https://images.pexels.com/photos/3063910/pexels-photo-3063910.jpeg?cs=srgb&dl=pexels-nappy-3063910.jpg&fm=jpg',
      'count': 326
    },
    {
      'title': 'Coffee\nDate',
      'imagePath':
          'https://images.pexels.com/photos/6315038/pexels-photo-6315038.jpeg?cs=srgb&dl=pexels-uriel-mont-6315038.jpg&fm=jpg',
      'count': 192
    },
    // Add more vibe cards here as needed
  ];

  @override
  Widget build(BuildContext context, ref) {
    final eventsProvider = ref.watch(allEventsProvider);
    final box = Hive.box(HiveConstants.hiveBox);
    final userProfile = box.get(HiveConstants.currentUserProf);
    final userPrifileModel = UserProfileModel.fromJson(userProfile);
    //  final arrangemennt = ref.watch(arrangementProvider);
    return Scaffold(
      backgroundColor: Teme.isDarktheme(prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: CustomAppBar(
                leading: CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                    onPressed: () {
                      Responsive.isDesktop(context)
                          ? ref.invalidate(arrangementProvider)
                          : Navigator.pop(context);
                    },
                    color: AppConstants.primaryColor,
                    icon: leftArrowSvg),
                title: Center(
                  child: AppRes.appLogo != null
                      ? Image.network(
                          AppRes.appLogo!,
                          height: 40,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          AppConstants.logo,
                          color: AppConstants.primaryColor,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            Expanded(
              // height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.defaultNumericValue),
                    PhotoVerifiedCard(
                        prefs: prefs, currentUserProf: userPrifileModel),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        top: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome to Explore',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Vibe!',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: (vibeCards.length / 2).ceil() *
                          MediaQuery.of(context).size.width *
                          0.7,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              (MediaQuery.of(context).size.width * 0.5) /
                                  (MediaQuery.of(context).size.width * 0.7),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: vibeCards.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              ref
                                  .watch(freeNumbersProvider(
                                index == 0
                                    ? 'lookingForLove'
                                    : index == 1
                                        ? 'freeTonight'
                                        : index == 2
                                            ? 'lookingForFriends'
                                            : index == 3
                                                ? 'coffeeDate'
                                                : index == 4
                                                    ? 'roadTrip'
                                                    : index == 5
                                                        ? 'stayTogether'
                                                        : 'letsGetMarried',
                              ))
                                  .whenData((eventNumbers) {
                                if (eventNumbers.isNotEmpty) {
                                  if (eventNumbers
                                      .contains(userPrifileModel.phoneNumber)) {
                                    if (!Responsive.isDesktop(context)) {
                                      Navigator.of(context).push(
                                        PageTransition(
                                          type: PageTransitionType.bottomToTop,
                                          child: EventSwipePage(
                                            prefs: prefs,
                                            currentUserProf: userPrifileModel,
                                            typeEvent: index == 0
                                                ? 'lookingForLove'
                                                : index == 1
                                                    ? 'freeTonight'
                                                    : index == 2
                                                        ? 'lookingForFriends'
                                                        : index == 3
                                                            ? 'coffeeDate'
                                                            : index == 4
                                                                ? 'roadTrip'
                                                                : index == 5
                                                                    ? 'stayTogether'
                                                                    : 'letsGetMarried',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(
                                            EventSwipePage(
                                              prefs: prefs,
                                              currentUserProf: userPrifileModel,
                                              typeEvent: index == 0
                                                  ? 'lookingForLove'
                                                  : index == 1
                                                      ? 'freeTonight'
                                                      : index == 2
                                                          ? 'lookingForFriends'
                                                          : index == 3
                                                              ? 'coffeeDate'
                                                              : index == 4
                                                                  ? 'roadTrip'
                                                                  : index == 5
                                                                      ? 'stayTogether'
                                                                      : 'letsGetMarried',
                                            ),
                                          );
                                    }
                                    ref
                                        .refresh(freeNumbersProvider(
                                          index == 0
                                              ? 'lookingForLove'
                                              : index == 1
                                                  ? 'freeTonight'
                                                  : index == 2
                                                      ? 'lookingForFriends'
                                                      : index == 3
                                                          ? 'coffeeDate'
                                                          : index == 4
                                                              ? 'roadTrip'
                                                              : index == 5
                                                                  ? 'stayTogether'
                                                                  : 'letsGetMarried',
                                        ))
                                        .value;
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Want to join?'),
                                          content: const Text(
                                              'You need to join this event to be able to swipe'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Ok'),
                                              onPressed: () async {
                                                await addUserToEventUsers(
                                                  userPrifileModel.phoneNumber,
                                                  index == 0
                                                      ? 'lookingForLove'
                                                      : index == 1
                                                          ? 'freeTonight'
                                                          : index == 2
                                                              ? 'lookingForFriends'
                                                              : index == 3
                                                                  ? 'coffeeDate'
                                                                  : index == 4
                                                                      ? 'roadTrip'
                                                                      : index ==
                                                                              5
                                                                          ? 'stayTogether'
                                                                          : 'letsGetMarried',
                                                );
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  PageTransition(
                                                    type: PageTransitionType
                                                        .bottomToTop,
                                                    child: EventSwipePage(
                                                      prefs: prefs,
                                                      currentUserProf:
                                                          userPrifileModel,
                                                      typeEvent: index == 0
                                                          ? 'lookingForLove'
                                                          : index == 1
                                                              ? 'freeTonight'
                                                              : index == 2
                                                                  ? 'lookingForFriends'
                                                                  : index == 3
                                                                      ? 'coffeeDate'
                                                                      : index ==
                                                                              4
                                                                          ? 'roadTrip'
                                                                          : index == 5
                                                                              ? 'stayTogether'
                                                                              : 'letsGetMarried',
                                                    ),
                                                  ),
                                                );
                                                ref
                                                    .refresh(
                                                        freeNumbersProvider(
                                                      index == 0
                                                          ? 'lookingForLove'
                                                          : index == 1
                                                              ? 'freeTonight'
                                                              : index == 2
                                                                  ? 'lookingForFriends'
                                                                  : index == 3
                                                                      ? 'coffeeDate'
                                                                      : index ==
                                                                              4
                                                                          ? 'roadTrip'
                                                                          : index == 5
                                                                              ? 'stayTogether'
                                                                              : 'letsGetMarried',
                                                    ))
                                                    .value;
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Want to join?'),
                                        content: const Text(
                                            'You need to join this event to be able to swipe'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Ok'),
                                            onPressed: () async {
                                              await addUserToEventUsers(
                                                userPrifileModel.phoneNumber,
                                                index == 0
                                                    ? 'lookingForLove'
                                                    : index == 1
                                                        ? 'freeTonight'
                                                        : index == 2
                                                            ? 'lookingForFriends'
                                                            : index == 3
                                                                ? 'coffeeDate'
                                                                : index == 4
                                                                    ? 'roadTrip'
                                                                    : index == 5
                                                                        ? 'stayTogether'
                                                                        : 'letsGetMarried',
                                              );
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  child: EventSwipePage(
                                                    prefs: prefs,
                                                    currentUserProf:
                                                        userPrifileModel,
                                                    typeEvent: index == 0
                                                        ? 'lookingForLove'
                                                        : index == 1
                                                            ? 'freeTonight'
                                                            : index == 2
                                                                ? 'lookingForFriends'
                                                                : index == 3
                                                                    ? 'coffeeDate'
                                                                    : index == 4
                                                                        ? 'roadTrip'
                                                                        : index ==
                                                                                5
                                                                            ? 'stayTogether'
                                                                            : 'letsGetMarried',
                                                  ),
                                                ),
                                              );
                                              ref.invalidate(
                                                  freeNumbersProvider(
                                                index == 0
                                                    ? 'lookingForLove'
                                                    : index == 1
                                                        ? 'freeTonight'
                                                        : index == 2
                                                            ? 'lookingForFriends'
                                                            : index == 3
                                                                ? 'coffeeDate'
                                                                : index == 4
                                                                    ? 'roadTrip'
                                                                    : index == 5
                                                                        ? 'stayTogether'
                                                                        : 'letsGetMarried',
                                              ));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                return eventNumbers;
                              });
                            },
                            child: VibeCard(
                              title: vibeCards[index]['title'],
                              imagePath: vibeCards[index]['imagePath'],
                              count: index == 0
                                  ? ref
                                      .watch(
                                          freeNumbersProvider("lookingForLove"))
                                      .value
                                      ?.length
                                  : index == 1
                                      ? ref
                                          .watch(freeNumbersProvider(
                                              "freeTonight"))
                                          .value
                                          ?.length
                                      : index == 2
                                          ? ref
                                              .watch(freeNumbersProvider(
                                                  "lookingForFriends"))
                                              .value
                                              ?.length
                                          : index == 3
                                              ? ref
                                                  .watch(freeNumbersProvider(
                                                      "coffeeDate"))
                                                  .value
                                                  ?.length
                                              : index == 4
                                                  ? ref
                                                      .watch(
                                                          freeNumbersProvider(
                                                              "roadTrip"))
                                                      .value
                                                      ?.length
                                                  : index == 5
                                                      ? ref
                                                          .watch(
                                                              freeNumbersProvider(
                                                                  "stayTogether"))
                                                          .value
                                                          ?.length
                                                      : ref
                                                          .watch(freeNumbersProvider(
                                                              "letsGetMarried"))
                                                          .value
                                                          ?.length,
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        top: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Events Nearby',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('People going to events nearby',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                    eventsProvider.when(
                        loading: () => const Center(
                              child: SizedBox(),
                            ),
                        error: (err, stack) => const Center(
                              child: SizedBox(),
                            ),
                        data: (events) {
                          return events.isNotEmpty
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: .8,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: EventSwipePage(
                                              prefs: prefs,
                                              currentUserProf: userPrifileModel,
                                              typeEvent: events[index].name,
                                            ),
                                          ));
                                        },
                                        child: VibeCard(
                                          title: events[index].name,
                                          imagePath: events[index].image,
                                          count: events[index].users.length,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox();
                        })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoVerifiedCard extends ConsumerWidget {
  final SharedPreferences prefs;
  final UserProfileModel currentUserProf;
  const PhotoVerifiedCard(
      {super.key, required this.prefs, required this.currentUserProf});

  @override
  Widget build(BuildContext context, ref) {
    final userList = ref
        .watch(freeNumbersProvider(
          'photoVerified',
        ))
        .value;
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
            image: NetworkImage(
                'https://images.pexels.com/photos/7480127/pexels-photo-7480127.jpeg?cs=srgb&dl=pexels-angela-roma-7480127.jpg&fm=jpg'),
            fit: BoxFit.cover),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      if (userList != null)
                        Text(
                          userList.length.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                const Text('Photo Verified',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          currentUserProf.isVerified
                              ? ref
                                  .watch(freeNumbersProvider(
                                  'photoVerified',
                                ))
                                  .whenData((eventNumbers) {
                                  addUserToEventUsers(
                                    currentUserProf.phoneNumber,
                                    'photoVerified',
                                  );
                                  Navigator.of(context).push(
                                    PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: EventSwipePage(
                                        isVerify: true,
                                        prefs: prefs,
                                        currentUserProf: currentUserProf,
                                        typeEvent: 'photoVerified',
                                      ),
                                    ),
                                  );

                                  return eventNumbers;
                                })
                              : showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Want to join?'),
                                      content: const Text(
                                          'You need to verify your profile to start swiping'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Ok'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              PageTransition(
                                                type: PageTransitionType
                                                    .bottomToTop,
                                                child: GetVerifiedPage(
                                                  user: currentUserProf,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: AppConstants.primaryColor,
                            backgroundColor: Colors.white),
                        child: Text((!currentUserProf.isVerified)
                            ? 'TRY NOW'
                            : 'SWIPE NOW'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image.asset('assets/verified_user.png', width: 100, height: 100),
        ],
      ),
    );
  }
}

class VibeCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final int? count;

  const VibeCard(
      {super.key, required this.title, required this.imagePath, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('${count ?? 0}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
