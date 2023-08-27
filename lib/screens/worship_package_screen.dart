import 'package:flutter/material.dart';

class WorshipPackageScreen extends StatefulWidget {
  const WorshipPackageScreen({super.key});

  @override
  State<WorshipPackageScreen> createState() => _WorshipPackageScreenState();
}

class _WorshipPackageScreenState extends State<WorshipPackageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Worship Package",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage("assets/images/image_haji.jpg"))),
                    ),
                  ),
                  const ListTile(
                    title: Text("Ibadah Haji"),
                    subtitle: Text("IDR 50.000.000"),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Card(
              color: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage("assets/images/image_umrah.jpg"))),
                    ),
                  ),
                  const ListTile(
                    title: Text("Ibadah Umrah"),
                    subtitle: Text("IDR 25.000.000"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
