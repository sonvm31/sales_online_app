import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/constants/app_styles.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const VNPayPaymentScreen({super.key, required this.paymentUrl});

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
    if (!kIsWeb) {
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
      _webViewController
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            if (url.contains('vnp_ResponseCode')) {
              final uri = Uri.parse(url);
              final responseCode = uri.queryParameters['vnp_ResponseCode'];
              if (responseCode == '00') {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, false);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán qua VNPay"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
