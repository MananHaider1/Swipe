import 'dart:io';

import 'package:document_selfie_verification/document_verification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class PhotoIdPage extends StatefulWidget {
  final PickedFileModel? frontView;
  final PickedFileModel? backView;
  const PhotoIdPage({
    super.key,
    this.frontView,
    this.backView,
  });

  @override
  State<PhotoIdPage> createState() => _PhotoIdPageState();
}

class _PhotoIdPageState extends State<PhotoIdPage> {
  PickedFileModel? _photoIdFrontView;
  PickedFileModel? _photoIdBackView;

  // final ImagePicker _picker = ImagePicker();

  void _onTapPicker(int index) async {
    await pickMediaAsData(isCamera: true).then((value) {
      if (value != null) {
        setState(() {
          if (index == 0) {
            _photoIdFrontView = value;
          } else {
            _photoIdBackView = value;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _photoIdFrontView = widget.frontView;
    _photoIdBackView = widget.backView;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(LocaleKeys.photoID.tr()),
      //   leading: BackButton(
      //     onPressed: () {
      //       if (_photoIdBackView != null && _photoIdFrontView != null) {
      //         Navigator.pop(context, [_photoIdFrontView!, _photoIdBackView!]);
      //       } else {
      //         Navigator.pop(context);
      //       }
      //     },
      //   ),
      // ),
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
                          if (_photoIdBackView != null &&
                              _photoIdFrontView != null) {
                            Navigator.pop(context,
                                [_photoIdFrontView!, _photoIdBackView!]);
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
              Text(LocaleKeys.pleasetakephotosoffrontandbackofyourofyourID.tr(),
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  !kIsWeb ?
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                  DocumentSelfieVerification(
                      side: SideType.frontSide,
                      // country: CountryType.fromString(AppRes.currentLocationProviderProvider!.addressText.split(",").last),
                                  country: CountryType.colombia,
                      onTakePhoto: (File response, EmojiType? emoji) async {
                        final file = await response.readAsBytes();
                        final filename = response.path.split('/').last;
                        _photoIdFrontView = PickedFileModel(
                          pickedFile: file,
                          fileName: filename,
                        );
                        // imageToShow = Image.file(response);
                        setState(() {});
                      }))) :
                   _onTapPicker(0);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * .27,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.38)),
                  ),
                  child: _photoIdFrontView == null
                      ? Center(
                          child: Text(LocaleKeys.frontView.tr()),
                        )
                      : Image(
                          image: MemoryImage(
                            _photoIdFrontView!.pickedFile!,
                          ),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  !kIsWeb ?
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentSelfieVerification(
                          side: SideType.backSide,
                          // country: CountryType.fromString(AppRes.currentLocationProviderProvider!.addressText.split(",").last),
                          country: CountryType.colombia,
                          onTakePhoto: (File response, EmojiType? emoji) async {
                            final file = await response.readAsBytes();
                            final filename = response.path.split('/').last;
                            _photoIdBackView = PickedFileModel(
                              pickedFile: file,
                              fileName: filename,
                            );
                            // imageToShow = Image.file(response);
                            setState(() {});
                          },
                        ),
                      ),
                    ) :
                   _onTapPicker(1);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * .27,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.38)),
                  ),
                  child: _photoIdBackView == null
                      ? Center(
                          child: Text(LocaleKeys.backView.tr()),
                        )
                      : Image(
                          image: MemoryImage(_photoIdFrontView!.pickedFile!),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const Expanded(child: SizedBox(height: 32)),
              _photoIdBackView != null && _photoIdFrontView != null
                  ? CustomButton(
                      text: LocaleKeys.save.tr(),
                      onPressed: () {
                        Navigator.pop(
                            context, [_photoIdFrontView!, _photoIdBackView!]);
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
