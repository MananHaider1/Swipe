import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

final currentUrlProvider = StateProvider<String>((ref) => "");

Future<void> listenToUrlChanges(
    PlatformWebViewController webViewController, ref) async {
  final url = await webViewController.currentUrl();
  ref.read(currentUrlProvider.notifier).state = url ?? "";
  webViewController.currentUrl().asStream().listen((url) {
    if (url != null) {
      ref.read(currentUrlProvider.notifier).state = url;
    }
  });
}
