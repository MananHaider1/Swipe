import 'package:lamatdating/modal/comment/comment.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:flutter/material.dart';

class ItemComment extends StatelessWidget {
  final CommentData commentData;
  final Function onRemoveClick;

  const ItemComment(this.commentData, this.onRemoveClick, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(icUserPlaceHolder),
                scale: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                commentData.userProfile!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        commentData.fullName!,
                        style: const TextStyle(
                          fontFamily: fNSfUiMedium,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Visibility(
                      visible:
                          commentData.phoneNumber == SessionManager.phoneNumber,
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () => onRemoveClick.call(),
                        child: const Icon(
                          Icons.delete,
                          color: AppConstants.hintColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  commentData.comment!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppConstants.hintColor,
                    fontFamily: fNSfUiRegular,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 0.3,
                  color: AppConstants.hintColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
