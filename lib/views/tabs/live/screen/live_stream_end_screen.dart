// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:restart_app/restart_app.dart';

class LivestreamEndScreen extends ConsumerStatefulWidget {
  final String time;
  final String watching;
  final String diamond;
  final String image;
  const LivestreamEndScreen({
    super.key,
    required this.time,
    required this.watching,
    required this.diamond,
    required this.image,
  });

  @override
  ConsumerState<LivestreamEndScreen> createState() =>
      _LivestreamEndScreenState();
}

class _LivestreamEndScreenState extends ConsumerState<LivestreamEndScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    prefData();
    super.initState();
  }

  void prefData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          // onPopInvoked: (pop) {
          //   if (pop == true) {
          //     Navigator.pop(context);
          //     Navigator.pop(context);
          //   }
          // },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  widget.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            widget.image,
                            height: MediaQuery.of(context).size.width / 2.5,
                            width: MediaQuery.of(context).size.width / 2.5,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox();
                            },
                          ))
                      : Image.asset(
                          icUserPlaceHolder,
                          height: MediaQuery.of(context).size.width / 2.5,
                          width: MediaQuery.of(context).size.width / 2.5,
                          fit: BoxFit.cover,
                          color: Colors.grey,
                        ),
                  ScaleTransition(
                    scale: _animation,
                    child: Text(
                      LocaleKeys.yourLiveStreamHasBeenEndednbelowIsASummaryOf
                          .tr(),
                      style:
                          const TextStyle(fontFamily: fNSfUiBold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SizeTransition(
                            sizeFactor: _animation,
                            axis: Axis.horizontal,
                            axisAlignment: -1,
                            child: Text(widget.time,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 30)),
                          ),
                          const SizedBox(
                            height: AppConstants.defaultNumericValue,
                          ),
                          Text(
                            LocaleKeys.streamFor.tr(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizeTransition(
                            sizeFactor: _animation,
                            axis: Axis.horizontal,
                            axisAlignment: -1,
                            child: Text(widget.watching,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 30)),
                          ),
                          const SizedBox(
                            height: AppConstants.defaultNumericValue,
                          ),
                          Text(
                            LocaleKeys.viewers.tr(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizeTransition(
                            sizeFactor: _animation,
                            axis: Axis.horizontal,
                            axisAlignment: -1,
                            child: Text(widget.diamond,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 30)),
                          ),
                          const SizedBox(
                            height: AppConstants.defaultNumericValue,
                          ),
                          Text(
                            '💎 ${LocaleKeys.collected.tr()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        !Responsive.isDesktop(context)
                            ? {await Restart.restartApp()}
                            : ref.invalidate(arrangementProvider);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) {

                        //       return const MyApp();
                        //     },
                        //   ),
                        // );
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            LocaleKeys.ok.tr(),
                            style: const TextStyle(
                                color: AppConstants.secondaryColor,
                                fontFamily: fNSfUiHeavy,
                                letterSpacing: 0.8,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
