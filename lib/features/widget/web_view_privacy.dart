import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/widget_support.dart';
import '../../common/constant/colors.dart';

class WebViewPrivacy extends StatefulWidget {
  const WebViewPrivacy({this.title, this.url});
  final String? title;
  final String? url;
  @override
  _WebViewPrivacyState createState() => _WebViewPrivacyState();
}

class _WebViewPrivacyState extends State<WebViewPrivacy> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(grey100)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url ?? 'your_link_policy'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context, title: widget.title ?? 'Term & Policy'),
      body: WebViewWidget(controller: controller),
    );
  }
}
