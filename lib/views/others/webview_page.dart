import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  int _progress = 0;

  @override
  void initState() {
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..loadRequest(Uri.parse(widget.url))
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..addJavaScriptChannel(
          "Toast",
          onMessageReceived: (p0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(p0.message)),
            );
          },
        )
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.prevent;
          },
        ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!kIsWeb)
            _progress != 100
                ? LinearProgressIndicator(
                    value: _progress.toDouble() / 100,
                  )
                : const Divider(height: 0),
          Expanded(child: WebViewWidget(controller: _webViewController)),
        ],
      ),
    );
  }
}
