import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';

class LoaderDialog extends StatelessWidget {
  const LoaderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppConstants.primaryColorDark,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }
}
