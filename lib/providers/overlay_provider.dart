// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final overlayProvider = Provider<OverlayState>((ref) => Overlay.of(ref.context!))..autoDispose();

// extension OverlayProviderExtensions on Provider<OverlayState> {
//   Future<void> showCustomBottomSheet(Widget sheet,) async {
//     final overlayState = ref.read;
//     return overlayState.insertOverlayEntry(OverlayEntry(builder: (context) => sheet));
//   }

//   Future<void> hideCustomBottomSheet() async {
//     final overlayState = ref.read;
//     overlayState.removeOverlay(overlayState.entries.last);
//   }
// }
