import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/broad_cast_screen_view_model.dart';

class LiveStreamBottomField extends ConsumerWidget {
  final BroadCastScreenViewModel? model;

  const LiveStreamBottomField({
    super.key,
    this.model,
  });

  @override
  Widget build(BuildContext context, ref) {
    TextEditingController controller = TextEditingController();
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.done,
                            minLines: 1,
                            maxLines: 5,
                            controller: model != null
                                ? model!.commentController
                                : controller,
                            focusNode: model != null
                                ? model!.commentFocus
                                : FocusNode(),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: LocaleKeys.comment.tr(),
                              contentPadding: const EdgeInsets.only(
                                  left: 15, bottom: 14, right: 1),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.70),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue * 2),
                          onTap: model != null ? model!.onComment : () {},
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            padding: const EdgeInsets.only(
                                left: 9, right: 10, top: 11, bottom: 8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppConstants.defaultGradient),
                            child: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              paperplaneIcon,
                              colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              // visible: !model!.isHost,
              visible: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () =>
                    model != null ? model!.onGiftTap(context, ref) : () {},
                child: Container(
                  height: 45,
                  width: 45,
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppConstants.defaultGradient,
                  ),
                  child: WebsafeSvg.asset(
                    height: 36,
                    width: 36,
                    fit: BoxFit.fitHeight,
                    giftIcon,
                   colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
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
    );
  }
}
