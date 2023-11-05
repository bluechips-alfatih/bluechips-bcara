// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:b_cara/extension/currency.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/screens/announc_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/padding.dart';
import 'package:provider/provider.dart';

class PaymentMethodController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }
}

class PaymentMethodScreen extends StatelessWidget {
  final int nominalTopUp;

  PaymentMethodScreen({
    Key? key,
    required this.nominalTopUp,
  }) : super(key: key);

  final PaymentMethodController _paymentMethodController =
      Get.put(PaymentMethodController());

  List<String> titles = [
    "BRI",
    "DANA",
  ];

  List<String> icons = ["assets/images/bri.png", "assets/images/dana.png"];
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
          'Payment Method',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: sizePadding,
          children: [
            const Text("Jumlah top up"),
            spaceHeight02,
            Text(
              nominalTopUp.toString().toRPCurrency(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            spaceHeight02,
            const Text("Metode Pembayaran"),
            spaceHeight02,
            Obx(
              () {
                return Row(
                  children: [
                    Expanded(
                      child: ToggleButtons(
                        direction: Axis.vertical,
                        isSelected: List.generate(
                          titles.length,
                          (index) =>
                              index ==
                              _paymentMethodController.selectedIndex.value,
                        ),
                        onPressed: (index) {
                          _paymentMethodController.setSelectedIndex(index);
                        },
                        renderBorder: false,
                        fillColor: Colors.blue.withOpacity(0.0),
                        splashColor: Colors.transparent,
                        children: List.generate(
                          titles.length,
                          (index) {
                            return Column(
                              children: [
                                Container(
                                  padding:
                                      sizePadding01 * 2 + sizePaddingvertical01,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _paymentMethodController
                                                .selectedIndex.value ==
                                            index
                                        ? blueColor
                                        : primaryColor,
                                    border: Border.all(
                                        width: 1,
                                        color: _paymentMethodController
                                                    .selectedIndex.value ==
                                                index
                                            ? blueColor
                                            : blueColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          icons[index],
                                          height: 40,
                                        ),
                                      ),
                                      spaceWidth01,
                                      Expanded(
                                        flex: 3,
                                        child: Text(titles[index],
                                            style: _paymentMethodController
                                                        .selectedIndex.value ==
                                                    index
                                                ? const TextStyle(
                                                    color: primaryColor)
                                                : const TextStyle(
                                                    color: blueColor)),
                                      ),
                                    ],
                                  ),
                                ),
                                spaceHeight03,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            spaceHeight02,
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final usersCoinCollection =
                      FirebaseFirestore.instance.collection('users_coin');
                  final userRef = FirebaseFirestore.instance
                      .collection('users_coin')
                      .doc(userProvider.getUser?.uid);

                  // Get the current user's data
                  final userSnapshot = await userRef.get();
                  final currentDanaUser = userSnapshot.data()?['danaUser'];

                  // Perform the transaction to update danaUser
                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final snapshotData = await transaction.get(userRef);
                    final currentDanaUser = snapshotData.get('danaUser') as int;
                    final updatedDanaUser = currentDanaUser + nominalTopUp;
                    transaction.update(userRef, {'danaUser': updatedDanaUser});
                  }).then((value) => Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const AnnounceScreen(
                                statusTransaksi: "success",
                              );
                            },
                          )));

                  print(_paymentMethodController.selectedIndex.value);

                  // Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                child: const Text(
                  "Top Up",
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
