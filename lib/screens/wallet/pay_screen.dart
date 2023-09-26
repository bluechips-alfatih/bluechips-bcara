import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/widgets/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,

        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset(AssetsManager.openAILogo),
        // ),
        title: const Text(
          'Pay',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(child: QRCodeScannerWidget()),
    );
  }
}
