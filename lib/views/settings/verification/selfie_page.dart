import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class SelfiePage extends StatefulWidget {
  final PickedFileModel? selfie;

  const SelfiePage({
    super.key,
    this.selfie,
  });

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  PickedFileModel? _selfie;

  void _onTapPicker() async {
    await pickMediaAsData(isCamera: true).then((value) {
      if (value != null) {
        setState(() {
          _selfie = value;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _selfie = widget.selfie;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: height * .17,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultNumericValue),
                  child: CustomAppBar(
                    leading: CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () {
                          if (_selfie != null) {
                            Navigator.pop(context, _selfie!);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                    title: Center(
                        child: CustomHeadLine(
                      // prefs: widget.prefs,
                      text: LocaleKeys.verification.tr(),
                    )),
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(LocaleKeys.pleasetakeclearaselfieofyourself.tr(),
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _onTapPicker,
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.38)),
                  ),
                  child: _selfie == null
                      ? Center(
                          child: Text(LocaleKeys.takeaselfie.tr()),
                        )
                      : Image(
                          image: MemoryImage(_selfie!.pickedFile!),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const Expanded(child: SizedBox(height: 32)),
              _selfie != null
                  ? CustomButton(
                      text: LocaleKeys.save.tr(),
                      onPressed: () {
                        Navigator.pop(context, _selfie!);
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
