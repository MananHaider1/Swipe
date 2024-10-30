import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentChatPeerProviderProvider =
    ChangeNotifierProvider<CurrentChatPeer>((ref) => CurrentChatPeer());

class CurrentChatPeer with ChangeNotifier {
  String? peerid = '';
  String? groupChatId = '';

  setpeer({
    String? newpeerid,
    String? newgroupChatId,
  }) {
    peerid = newpeerid ?? peerid;
    groupChatId = newgroupChatId ?? groupChatId;
    notifyListeners();
  }
}
