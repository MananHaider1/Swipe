import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/models/meeting_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/meeting_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

class MeetingsPage extends ConsumerStatefulWidget {
  const MeetingsPage({super.key});

  @override
  ConsumerState<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends ConsumerState<MeetingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Access the list of meetings from the provider
    final meetings = ref.watch(getMeetingsProvider);
    final prefs = ref.watch(sharedPreferences).value;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Teme.isDarktheme(prefs!)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: meetings.when(
        data: (data) {
          final meetings = data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue,
                  top: MediaQuery.of(context).padding.top,
                ),
                child: CustomAppBar(
                  leading: Row(children: [
                    CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () {
                          (!Responsive.isDesktop(context))
                              ? Navigator.pop(context)
                              : ref.invalidate(arrangementProviderExtend);
                        },
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                  ]),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.meetups.tr(),
                  )),
                  trailing: CustomIconButton(
                    icon: ellipsisIcon,
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 5.0),
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Teme.isDarktheme(prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  title: Center(
                                      child: Text(
                                    LocaleKeys.meetup.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                                  content: SizedBox(
                                    height: height * .9,
                                    width: width * .9,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(
                                              height: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          Container(
                                              height: height * .06,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .secondaryColor
                                                        .withOpacity(.1)
                                                    : AppConstants.primaryColor
                                                        .withOpacity(.1),
                                              ),
                                              child: ListTile(
                                                title: Text(meeting.status,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium),
                                              )),
                                          const SizedBox(
                                              height: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          Container(
                                              height: height * .12,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .secondaryColor
                                                        .withOpacity(.1)
                                                    : AppConstants.primaryColor
                                                        .withOpacity(.1),
                                              ),
                                              child: ListTile(
                                                  title: Text(
                                                      meeting.meetingVenue),
                                                  subtitle: Text(
                                                    '${meeting.meetingDate.toString()} - ${meeting.meetingStartTime} - ${meeting.meetingEndTime}',
                                                  ),
                                                  trailing: CustomIconButton(
                                                    padding: const EdgeInsets
                                                        .all(AppConstants
                                                                .defaultNumericValue /
                                                            1.8),
                                                    color: AppConstants
                                                        .primaryColor,
                                                    icon: commentIcon,
                                                    onPressed: () {},
                                                  ))),
                                          const SizedBox(
                                              height: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          Container(
                                              height: height * .06,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .secondaryColor
                                                        .withOpacity(.1)
                                                    : AppConstants.primaryColor
                                                        .withOpacity(.1),
                                              ),
                                              child: ListTile(
                                                title: Text("${meeting.budget}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium),
                                              )),
                                          const SizedBox(
                                              height: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          Container(
                                              height: height * .15,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .secondaryColor
                                                        .withOpacity(.1)
                                                    : AppConstants.primaryColor
                                                        .withOpacity(.1),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                    "${meeting.description}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium),
                                              )),
                                          const SizedBox(
                                              height: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          // images grid
                                          SizedBox(
                                            height: height * .25,
                                            child: GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 1,
                                                crossAxisSpacing: 2,
                                                mainAxisSpacing: 2,
                                              ),
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SinglePhotoViewPage(
                                                                images: meeting
                                                                    .images,
                                                                index: index,
                                                                title:
                                                                    LocaleKeys
                                                                        .images
                                                                        .tr()),
                                                      ),
                                                    );
                                                  },
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        meeting.images[index],
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive(),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return const Center(
                                                        child: Icon(Icons
                                                            .image_not_supported),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              itemCount: meeting.images.length,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(LocaleKeys.close.tr(),
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          LocaleKeys.accept.tr(),
                                        )),
                                  ],
                                );
                              },
                            );
                          },
                          child: MeetingItem(meeting: meeting, prefs: prefs)),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (_, __) => const ErrorPage(),
        loading: () => const LoadingPage(),
      ),
    );
  }
}

class MeetingItem extends StatelessWidget {
  final MeetingModel meeting;
  final SharedPreferences prefs;

  const MeetingItem({super.key, required this.meeting, required this.prefs});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
        width: width,
        height: height * .1,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Teme.isDarktheme(prefs)
              ? AppConstants.secondaryColor.withOpacity(.1)
              : AppConstants.primaryColor.withOpacity(.1),
        ),
        child: ListTile(
            title: Text(meeting.meetingVenue),
            subtitle: Text(
              '${meeting.meetingDate.toString()} - ${meeting.meetingStartTime} - ${meeting.meetingEndTime}',
            ),
            trailing: CustomIconButton(
              padding:
                  const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
              color: AppConstants.primaryColor,
              icon: commentIcon,
              onPressed: () {},
            )));
  }
}
