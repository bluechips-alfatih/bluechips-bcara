import 'package:b_cara/responsive/mobile_screen_layout.dart';
import 'package:b_cara/responsive/responsive_layout.dart';
import 'package:b_cara/responsive/web_screen_layout.dart';
import 'package:b_cara/utils/padding.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnnounceScreen extends StatelessWidget {
  const AnnounceScreen(
      {super.key, required this.statusTransaksi, this.kodeTransaksi = "topup"});
  final String statusTransaksi;
  final String kodeTransaksi;

  String getAnimationPath() {
    if (statusTransaksi == "success") {
      return 'assets/lottie/payment_success.json';
    } else if (statusTransaksi == "pending") {
      return 'assets/lottie/payment_pending.json';
    } else if (statusTransaksi == "deny") {
      return 'assets/lottie/payment_failed.json';
    } else {
      return '';
    }
  }

  String getStatusText() {
    if (kodeTransaksi == "topup") {
      return 'Top Up Success';
    } else if (kodeTransaksi == "transfer") {
      return 'Transfer Success';
    } else if (statusTransaksi == "deny") {
      return 'Payment Failed';
    } else {
      return 'Unknown Status';
    }
  }

  Color getStatusColor() {
    if (statusTransaksi == "success") {
      return Colors.green;
    } else if (statusTransaksi == "pending") {
      return Colors.orange;
    } else if (statusTransaksi == "deny") {
      return Colors.red;
    } else {
      return Colors.black; // Warna default jika status tidak dikenali
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: sizePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(getAnimationPath()),
            const SizedBox(height: 20),
            Text(getStatusText(), // Menggunakan fungsi getStatusText()
                style: TextStyle(color: getStatusColor())),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const ResponsiveLayout(
                          mobileScreenLayout: MobileScreenLayout(),
                          webScreenLayout: WebScreenLayout(),
                        ),
                      ),
                      (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                child: const Text(
                  "Go Home",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
