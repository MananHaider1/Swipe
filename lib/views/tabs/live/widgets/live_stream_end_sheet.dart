import 'package:lamatdating/constants.dart';
import 'package:flutter/material.dart';

class LiveStreamEndSheet extends StatelessWidget {
  final String name;
  final VoidCallback onExitBtn;

  const LiveStreamEndSheet(
      {super.key, required this.name, required this.onExitBtn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onExitBtn,
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                  color: Colors.black, fontSize: 20, fontFamily: fNSfUiBold),
            ),
            const Text(
              'Live Stream Ended',
              style: TextStyle(
                  color: Colors.black, fontSize: 19, fontFamily: fNSfUiRegular),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
