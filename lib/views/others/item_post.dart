import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/session_manager.dart';

import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/views/video/video_list_screen.dart';

class ItemPost extends StatelessWidget {
  final TeelsModel? data;
  final List<TeelsModel>? list;
  final Function? onTap;
  final String? type;
  final String? phoneNumber;
  final String? soundId;

  const ItemPost(
      {super.key,
      required this.data,
      this.onTap,
      this.list,
      this.type,
      this.phoneNumber,
      this.soundId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () {
            onTap?.call();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoListScreen(
                  list: list,
                  index: list!.indexOf(data!),
                  type: type,
                  phoneNumber: phoneNumber,
                  soundId: soundId,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            margin: const EdgeInsets.only(top: 10, right: 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                color: AppConstants.backgroundColor,
                child: Image(
                  image: NetworkImage(
                    (data?.thumbnail ?? ''),
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          child: Row(
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              Text(
                NumberFormatter.formatter(
                  data!.views.length.toString(),
                ),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
