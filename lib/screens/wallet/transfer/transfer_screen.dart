import 'package:b_cara/screens/wallet/transfer/tab/transfer_cash.dart';
import 'package:b_cara/screens/wallet/transfer/tab/transfer_voucher.dart';
import 'package:flutter/material.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Specify the number of tabs
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          title: const Text(
            'Transfer',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(
                text: 'Transfer Voucher',
              ),
              Tab(
                text: 'Transfer Cash',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            TransferVoucher(),

            // Add the content for Tab 2 here
            TransferCash()
          ],
        ),
      ),
    );
  }
}
