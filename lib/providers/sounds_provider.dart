import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/sounds_model.dart';
import 'package:lamatdating/helpers/my_loading/my_loading.dart';
import 'package:rxdart/rxdart.dart';

// final soundListProvider = StreamProvider.autoDispose<List<SoundData>>((ref) {
//   return FirebaseFirestore.instance
//       .collection(FirebaseConstants.soundList)
//       .snapshots()
//       .map((snapshot) {
//     return snapshot.docs.map((doc) {
//       return SoundData.fromJson(doc.data());
//     }).toList();
//   });
// });

// final soundListProvider = StreamProvider.autoDispose<List<SoundData>>((ref) {
//   return FirebaseFirestore.instance
//       .collection(FirebaseConstants.soundList)
//       .snapshots()
//       .map((snapshot) {
//     final lists = snapshot.docs.map((doc) {
//       return SoundCategory.fromJson(doc.data());
//     }).toList();

//   });
// });

final soundListProvider = StreamProvider.autoDispose<List<SoundData>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.soundList)
      .snapshots()
      .map((snapshot) {
    // Get all SoundCategory objects
    final soundDataList =
        snapshot.docs.map((doc) => SoundCategory.fromJson(doc.data())).toList();

    // Flatten the nested soundList lists
    final mergedSoundList = soundDataList
        .expand((soundData) => (soundData.soundList as List<SoundData>))
        .toList();

    return mergedSoundList;
  });
});

final soundListSearchProvider =
    StreamProvider.autoDispose<List<SoundData>>((ref) {
  final searchText = ref.watch(myLoadingProvider).musicSearchText;
  // final songsList = ref.watch(soundListProvider).value;

  if (searchText.isEmpty) {
    // If searchText is empty, return all songs without filtering
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.soundList)
        .snapshots()
        .map((snapshot) {
      // Get all SoundCategory objects
      final soundDataList = snapshot.docs
          .map((doc) => SoundCategory.fromJson(doc.data()))
          .toList();

      // Flatten the nested soundList lists
      final mergedSoundList = soundDataList
          .expand((soundData) => soundData.soundList as List<SoundData>)
          .toList();

      return mergedSoundList;
    });
  } else {
    final soundTitleSearch = FirebaseFirestore.instance
        .collection(FirebaseConstants.soundList)
        .snapshots()
        .map((snapshot) {
      // Get all SoundCategory objects
      final soundDataList = snapshot.docs
          .map((doc) => SoundCategory.fromJson(doc.data()))
          .toList();

      // Flatten the nested soundList lists
      final mergedSoundList = soundDataList
          .expand((soundData) => soundData.soundList as List<SoundData>)
          .toList()
          .where((element) => element.soundTitle!.contains(searchText));
      return mergedSoundList;
    });

    final soundSingerSearch = FirebaseFirestore.instance
        .collection(FirebaseConstants.soundList)
        .snapshots()
        .map((snapshot) {
      // Get all SoundCategory objects
      final soundDataList = snapshot.docs
          .map((doc) => SoundCategory.fromJson(doc.data()))
          .toList();

      // Flatten the nested soundList lists
      final mergedSoundList = soundDataList
          .expand((soundData) => soundData.soundList as List<SoundData>)
          .toList()
          .where((element) => element.singer!.contains(searchText));
      return mergedSoundList;
    });

    final combinedStream = Rx.merge([
      soundTitleSearch.map((soundList) => soundList),
      soundSingerSearch.map((soundList) => soundList),
    ]);

    return combinedStream as Stream<List<SoundData>>;
  }
});


// final Stream<List<SoundData>> soundListStream = FirebaseFirestore.instance
//     .collection(FirebaseConstants.soundList)
//     .snapshots()
//     .map((snapshot) {
//   return snapshot.docs.map((doc) {
//     return SoundData.fromJson(doc.data());
//   }).toList();
// });


// final getSearchSoundListProvider =
//     FutureProvider.family<List<SoundData>, String>((ref, searchText) async {
//   final soundListAsyncValue =
//       ref.watch(soundListProvider as AlwaysAliveProviderListenable);
//   final soundList = soundListAsyncValue.maybeWhen(
//     data: (data) => data,
//     orElse: () => [],
//   );
//   return soundList
//       .where((sound) => sound.soundTitle.contains(searchText))
//       .toList();
// });
