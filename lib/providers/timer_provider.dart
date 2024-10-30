import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';

final timerProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier());

class TimerState {
  TimerState(
      {required this.wait, required this.start, required this.isActionBarShow});
  final bool wait;
  final int start;
  final bool isActionBarShow;
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
      : super(TimerState(
            wait: false, start: timeOutSeconds, isActionBarShow: false));

  startTimer() {
    const onsec = Duration(seconds: 1);
    Timer.periodic(onsec, (timer) {
      if (state.start == 0) {
        timer.cancel();
        state =
            TimerState(wait: false, start: state.start, isActionBarShow: true);
      } else {
        state = TimerState(
            wait: true,
            start: state.start - 1,
            isActionBarShow: state.isActionBarShow);
      }
    });
  }

  resetTimer() {
    state = TimerState(
        wait: state.wait, start: timeOutSeconds, isActionBarShow: false);
  }
}


// import 'dart:async';

// import 'package:lamatdating/v3/Configs/optional_constants.dart';
// import 'package:flutter/foundation.dart';

// class TimerProvider with ChangeNotifier {
//   bool wait = false;
//   int start = timeOutSeconds;
//   bool isActionBarShow = false;
//   startTimer() {
//     const onsec = Duration(seconds: 1);
//     // ignore: unused_local_variable
//     Timer _timer = Timer.periodic(onsec, (timer) {
//       if (start == 0) {
//         timer.cancel();
//         wait = false;
//         isActionBarShow = true;
//         notifyListeners();
//       } else {
//         start--;
//         wait = true;
//         notifyListeners();
//       }
//     });
//   }

//   resetTimer() {
//     start = timeOutSeconds;
//     isActionBarShow = false;
//     notifyListeners();
//   }
// }
