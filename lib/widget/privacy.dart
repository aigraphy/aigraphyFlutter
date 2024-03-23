import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_helper.dart';

class Privacy extends StatefulWidget {
  const Privacy({this.title, this.url});
  final String? title;
  final String? url;
  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.facebook.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url ?? linkPolicy));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AigraphyWidget.createSimpleAppBar(
          context: context, title: widget.title ?? 'Term & Policy'),
      body: WebViewWidget(controller: controller),
    );
  }
}
