import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/constants.dart';

class CustomBottomSheet extends StatefulWidget {
  final Widget child;
  final Function onClose;

  const CustomBottomSheet({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> show() async {
    await _animationController.forward();
  }

  Future<void> hide() async {
    await _animationController.reverse();
    widget.onClose(); // Notify parent about closing the sheet
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10.0,
            spreadRadius: 5.0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: AppConstants.defaultNumericValue,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                InkWell(
                    onTap: () {
                      hide;
                    },
                    child: WebsafeSvg.asset(
                      closeIcon,
                     colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                      height: 32,
                      width: 32,
                      fit: BoxFit.fitHeight,
                    )),
                SizedBox(
                  width: width * .3,
                ),
                Container(
                    width: AppConstants.defaultNumericValue * 3,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppConstants.hintColor,
                    )),
              ]),
          widget.child,
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  final double radius;

  const CustomClipPath({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.quadraticBezierTo(
        0.0, size.height - radius, radius, size.height - radius);
    path.lineTo(size.width - radius, size.height - radius);
    path.quadraticBezierTo(size.width, size.height - radius, size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipPath oldClipper) => oldClipper.radius != radius;
}
