import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';

class UserCirlePicture extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  const UserCirlePicture({
    super.key,
    required this.imageUrl,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final newSize = size ?? AppConstants.defaultNumericValue * 5;
    return Container(
      width: newSize,
      height: newSize,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultNumericValue * 10),
        border: Border.all(color: AppConstants.primaryColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultNumericValue * 10),
        child: imageUrl == null || imageUrl!.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: AppConstants.primaryColor,
                  size: newSize * 0.8,
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
