// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum PageArrangement {
//   chat,
//   swipe,
//   profileOnSwipe,
//   planMeetOnSwipe,
//   profileOnTeels,
//   editProfile,
//   viewImage,
//   settings,
// }

// Widget? page;

final arrangementProvider = StateNotifierProvider<ArrangementNotifier, Widget?>(
  (ref) => ArrangementNotifier(null),
);

class ArrangementNotifier extends StateNotifier<Widget?> {
  ArrangementNotifier(super.initialPage); // Default arrangement

  void setArrangement(Widget newArrangement) {
    state = newArrangement;
  }
}

final arrangementProviderExtend =
    StateNotifierProvider<ArrangementNotifierExtend, Widget?>(
  (ref) => ArrangementNotifierExtend(null),
);

class ArrangementNotifierExtend extends StateNotifier<Widget?> {
  ArrangementNotifierExtend(super.initialPage); // Default arrangement

  void setArrangement(Widget newArrangement) {
    state = newArrangement;
  }
}

final currentIndexProvider = StateProvider<int>((ref) => 0); // Initial index 0

void updateCurrentIndex(WidgetRef ref, int newIndex) {
  ref.read(currentIndexProvider.notifier).state = newIndex;
}
