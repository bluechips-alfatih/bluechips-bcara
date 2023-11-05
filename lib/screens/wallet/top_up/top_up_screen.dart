import 'package:b_cara/extension/currency.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/screens/wallet/top_up/payment_method.dart';
import 'package:b_cara/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  @override
  List<bool> isSelected = List.generate(6, (index) => false);
  int selectedMoneyIndex = -1;
  int? moneyTopUp;
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
          'Top Up',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Text(
                    "Pilih Nominal",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  final moneyValues = [
                    15000,
                    30000,
                    50000,
                    100000,
                    200000,
                    500000
                  ];
                  final moneyText = "${moneyValues[index]}".toRPCurrency();
                  final isSelectedItem = selectedMoneyIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMoneyIndex = index;
                        moneyTopUp = moneyValues[index];
                      });
                    },
                    child: Card(
                      color: isSelectedItem ? Colors.blue : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/money.png",
                              width: 80, height: 80),
                          const SizedBox(height: 10),
                          Text(
                            moneyText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (moneyTopUp == null) {
                      showToast("Silahkan pilih nominal, terlebih dahulu");
                    } else {
                      print(moneyTopUp);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return PaymentMethodScreen(
                            nominalTopUp: moneyTopUp!,
                          );
                        },
                      ));
                    }

                    // Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    "Pilih Metode Pembayaran",
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
