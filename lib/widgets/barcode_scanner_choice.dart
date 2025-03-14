import 'package:flutter/material.dart';
import 'barcode_scanner.dart';

class BarcodeScannerChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Scan Method")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BarcodeScannerScreen(scanFromGallery: false),
                  ),
                );
              },
              child: Text("Scan Using Camera"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BarcodeScannerScreen(scanFromGallery: true),
                  ),
                );
              },
              child: Text("Scan From Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
