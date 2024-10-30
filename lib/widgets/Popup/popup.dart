import 'package:flutter/material.dart';

class CustomPopup extends StatefulWidget {
  const CustomPopup({super.key});

  @override
  CustomPopupState createState() => CustomPopupState();
}

class CustomPopupState extends State<CustomPopup> {
  bool isPopupVisible = false;

  void showPopup() {
    setState(() {
      isPopupVisible = true;
    });
  }

  void hidePopup() {
    setState(() {
      isPopupVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: showPopup,
      child: const Text('Show Popup'),
    );
  }

  Widget buildPopupContent() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/popup_image.png'), // Replace with your image
            const Text('This is a custom popup!'),
            // Add more widgets as needed
            ElevatedButton(
              onPressed: hidePopup,
              child: const Text('Close'),
            )
          ],
        ),
      ),
    );
  }
}
