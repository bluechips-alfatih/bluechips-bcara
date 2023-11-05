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

class TransferVoucher extends StatefulWidget {
  const TransferVoucher({super.key});

  @override
  State<TransferVoucher> createState() => _TransferVoucherState();
}

class _TransferVoucherState extends State<TransferVoucher> {
  final TextEditingController _walletAddress = TextEditingController();

  final TextEditingController _dccCoin = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _walletAddress.dispose();
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              spaceHeight02,
              const Text(
                "Transfer Voucher",
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
                    'Wallet Address',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Wallet Address',
                    fillColor: Colors.white,
                    filled: true),
                validator: (value) {
                  if (value == "") {
                    return 'Please enter a wallet address';
                  }
                  return null;
                },
                controller: _walletAddress,
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Total Voucher to Transfer',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Voucher Sent',
                    fillColor: Colors.white,
                    filled: true),
                validator: (value) {
                  if (value == "") {
                    return 'Please enter DCC to Sent';
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
              const Text("Value Voucher in IDR",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              Card(
                color: Colors.white,
                child: Text(
                    _dccCoin.text.isNotEmpty
                        ? NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ')
                            .format(int.parse(_dccCoin.text) * 15000)
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
                      final coinBalance = userDoc.get('totalCoinUser') as int;

                      final dccCoin = int.parse(_dccCoin.text);

                      if (dccCoin > coinBalance) {
                        // Get.showSnackbar(const GetSnackBar(
                        //   title: "hai",
                        // ));
                        Get.snackbar("Insufficient Coins",
                            "You don't have enough coins to perform this transaction.",
                            snackPosition: SnackPosition.TOP,
                            colorText: Colors.white);
                        print(" aaa");
                      } else {
                        final walletAddressToFind = _walletAddress
                            .text; // Ganti dengan wallet_address yang ingin Anda cari
                        final usersCoinCollection =
                            FirebaseFirestore.instance.collection('users_coin');

// Lakukan query untuk mencari UID berdasarkan wallet_address
                        final querySnapshot = await usersCoinCollection
                            .where('walletAddress',
                                isEqualTo: walletAddressToFind)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          // Dapatkan UID dari dokumen pertama yang cocok (jika ada lebih dari satu, gunakan yang pertama)
                          final uidPenerima = querySnapshot.docs[0].id;

                          // Sekarang Anda memiliki UID penerima dan dapat melanjutkan dengan kode Anda untuk mengirim koin ke UID tersebut.
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final userSend =
                                usersCoinCollection.doc(uidPenerima);
                            final snapshot = await transaction.get(userSend);
                            final currentCoin =
                                snapshot.get('totalCoinUser') as int;
                            final updatedCoin = currentCoin + dccCoin;
                            transaction.update(
                                userSend, {'totalCoinUser': updatedCoin});
                          });
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            //user sendiri berkurang poin karena dikirim

                            final snapshotData = await transaction.get(userRef);
                            final currentCoinUser =
                                snapshotData.get('totalCoinUser') as int;
                            final updatedCoinUser = currentCoinUser - dccCoin;
                            transaction.update(
                                userRef, {'totalCoinUser': updatedCoinUser});
                          }).then((value) => Navigator.of(context)
                                  .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AnnounceScreen(
                                                statusTransaksi: "success",
                                                kodeTransaksi: "transfer",
                                              )),
                                      (route) => false));
                        } else {
                          Get.snackbar("Wallet Address Not Found",
                              "The Wallet Address for the user could not be found.",
                              snackPosition: SnackPosition.TOP,
                              colorText: Colors.white);

                          // Tidak ada pengguna dengan wallet_address yang sesuai ditemukan, tangani dengan cara yang sesuai.
                          print(
                              'Tidak ada pengguna dengan wallet_address yang sesuai.');
                        }
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
