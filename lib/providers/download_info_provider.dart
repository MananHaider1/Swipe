import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadInfoProviderProvider =
    ChangeNotifierProvider<DownloadInfoprovider>(
        (ref) => DownloadInfoprovider());

class DownloadInfoprovider with ChangeNotifier {
  int totalsize = 0;
  double downloadedpercentage = 0.0;
  calculatedownloaded(
    double newdownloadedpercentage,
    int newtotal,
  ) {
    totalsize = newtotal;
    downloadedpercentage = newdownloadedpercentage;
    notifyListeners();
  }
}
