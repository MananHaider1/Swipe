// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/auth_providers.dart';
// import 'package:tuple/tuple.dart';

// import 'other_users_provider.dart';

// final addCommentProvider = Provider.family<void,
//         Tuple4<UserProfileModel, UserProfileModel, String, DateTime, WidgetRef>>(
//     (ref, data, reff) async {
//   final commentText = data.item3;
//   final date = data.item4;
//   final otherUsersRef = ref.watch(otherUsersProvider(reff));
//   final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;

//   final comments = FirebaseFirestore.instance.collection('comments');

//   await comments.add({
//     'senderUserId': currentUserId,
//     'receiverUserId': otherUsersRef,
//     'commentText': commentText,
//     'date': date
//   });
// });
