import 'package:b_cara/extension/currency.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/responsive/mobile_screen_layout.dart';
import 'package:b_cara/responsive/responsive_layout.dart';
import 'package:b_cara/responsive/web_screen_layout.dart';
import 'package:b_cara/screens/announc_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/padding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransferCash extends StatefulWidget {
  const TransferCash({super.key});

  @override
  State<TransferCash> createState() => _TransferCashState();
}

class _TransferCashState extends State<TransferCash> {
  final TextEditingController _dccCoin = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _dccCoin.dispose();
    super.dispose();
  }

  void _updateResult() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    Stream<int?> danaBalanceStream() {
      final user = userProvider.getUser;
      if (user == null || user.uid.isEmpty) {
        // Handle the case when the user or UID is null or empty
        return Stream.value(null);
      }

      final userRef =
          FirebaseFirestore.instance.collection('users_coin').doc(user.uid);

      return userRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return snapshot.get('danaUser') as int?;
        } else {
          return null;
        }
      });
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              spaceHeight02,
              const Text(
                "Transfer Cash",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 16,
              ),
              const Row(
                children: [
                  Text(
                    'Cash Anda',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              spaceHeight02,
              Row(
                children: [
                  StreamBuilder<int?>(
                      stream: danaBalanceStream(),
                      builder: (context, snapshot) {
                        final danaBalance = snapshot.data;

                        print("danaBalance $danaBalance");
                        return Text(
                          danaBalance != null
                              ? "$danaBalance".toIDRCurrency()
                              : "IDR 0",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        );
                      }),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Total Cash to Voucher',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Voucher Sent',
                    fillColor: Colors.white,
                    filled: true),
                validator: (value) {
                  if (value == "") {
                    return 'Please enter Voucher to Sent';
                  }
                  final doubleValue = double.tryParse(value!);
                  if (doubleValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (doubleValue <= 0) {
                    return 'Please enter a value greater than zero';
                  }
                  return null;
                },
                controller: _dccCoin,
                onChanged: (value) {
                  _updateResult();
                },
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Total Voucher yang akan diterima",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              Card(
                color: Colors.white,
                child: Text(
                    _dccCoin.text.isNotEmpty
                        ? '${(int.parse(_dccCoin.text) / 15000).toStringAsFixed(1)} Voucher'
                        : '0,00',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // var walletUser =
                      //     await PreferenceHandler.retrieveWalletAddress();
                      final userRef = FirebaseFirestore.instance
                          .collection('users_coin')
                          .doc(userProvider.getUser?.uid);
                      final userDoc = await userRef.get();
                      final danaBalance = userDoc.get('danaUser') as int;
                      final getVoucher = int.parse(_dccCoin.text) / 15000;
                      final inputCash = int.parse(_dccCoin.text);

                      if (inputCash > danaBalance) {
                        // Get.showSnackbar(const GetSnackBar(
                        //   title: "hai",
                        // ));
                        Get.snackbar("Insufficient Cash",
                            "You don't have enough cash to perform this transaction.",
                            snackPosition: SnackPosition.TOP,
                            colorText: Colors.white);
                        print(" aaa");
                      } else {
                        final usersCoinCollection =
                            FirebaseFirestore.instance.collection('users_coin');
                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          final userSend = usersCoinCollection
                              .doc(userProvider.getUser!.uid);
                          final snapshot = await transaction.get(userSend);
                          final currentCoin =
                              snapshot.get('totalCoinUser') as double;
                          final updatedCoin = currentCoin + getVoucher;
                          transaction
                              .update(userSend, {'totalCoinUser': updatedCoin});
                        });
                        await FirebaseFirestore.instance.runTransaction(
                            (transaction) async {
                          //user sendiri berkurang poin karena dikirim

                          final snapshotData = await transaction.get(userRef);
                          final currentDanaUser =
                              snapshotData.get('danaUser') as int;
                          final updatedCoinUser = currentDanaUser - inputCash;
                          transaction
                              .update(userRef, {'danaUser': updatedCoinUser});
                        }).then(
                            (value) => Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const AnnounceScreen(
                                          statusTransaksi: "success",
                                          kodeTransaksi: "transfer",
                                        )),
                                (route) => false));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    "TRANSFER NOW",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
