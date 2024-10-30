// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:document_selfie_verification/document_verification.dart';
import 'package:logger/logger.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/date_formater.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/models/verification_form_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/verification_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/settings/verification/photo_id_page.dart';
import 'package:lamatdating/views/settings/verification/selfie_page.dart';

// Future<void> setPortrait() async {
//   await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
// }

class GetVerifiedPage extends ConsumerStatefulWidget {
  final UserProfileModel user;

  const GetVerifiedPage({super.key, required this.user});

  @override
  ConsumerState<GetVerifiedPage> createState() => _GetVerifiedPageState();
}

class _GetVerifiedPageState extends ConsumerState<GetVerifiedPage> {
  bool _submitAgain = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await setPortrait();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final verificationData = ref.watch(verificationProvider);
    final currentUserRef = ref.watch(currentUserStateProvider);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(LocaleKeys.verification.tr()),
        // ),
        body: Column(children: [
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
                  Navigator.pop(context);},
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
      ListTile(
        leading: const Icon(Icons.verified_user),
        title: Text(LocaleKeys.status.tr()),
        subtitle: Text(
          widget.user.isVerified
              ? LocaleKeys.verified.tr()
              : LocaleKeys.notverified.tr(),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.user.isVerified ? Colors.green : Colors.red),
        ),
        // onTap: (widget.user.isVerified)
        //     ? null
        //     : () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   GetVerifiedPage(user: widget.user)),
        //         );
        //       },
      ),
      const Divider(),
      Expanded(
        child: SizedBox(
          // height: height * .83,
          child: _submitAgain
              ? const _NotVerifiedPart(submitAgain: true)
              : widget.user.isVerified
                  ? const SizedBox()
                  : FutureBuilder<VerificationFormModel?>(
                      future: verificationData
                          .getVerifiedStatus(currentUserRef!.phoneNumber!),
                      builder: (BuildContext context,
                          AsyncSnapshot<VerificationFormModel?> snapshot) {
                        return snapshot.hasError
                            ? Center(
                                child: Text(LocaleKeys.error.tr()),
                              )
                            : snapshot.data == null
                                ? const _NotVerifiedPart(submitAgain: false)
                                : _VerifiedPart(
                                    data: snapshot.data!,
                                    onPressedSubmitAgain: () {
                                      setState(() {
                                        _submitAgain = true;
                                      });
                                    },
                                  );
                      },
                    ),
        ),
      )
    ]));
  }
}

class _VerifiedPart extends StatelessWidget {
  final VerificationFormModel data;
  final VoidCallback onPressedSubmitAgain;
  const _VerifiedPart({
    required this.data,
    required this.onPressedSubmitAgain,
  });

  @override
  Widget build(BuildContext context) {
    bool isNotApproved = data.isPending == false && data.isApproved == false;

    bool isVerified = data.isPending == false && data.isApproved == true;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
      child: Center(
        child: isVerified
            ? Text(
                LocaleKeys.youraccountisverifiedRestarttheapptoseethechanges
                    .tr(),
                textAlign: TextAlign.center,
              )
            : Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        isNotApproved
                            ? Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: MediaQuery.of(context).size.width * 0.15,
                              )
                            : Icon(
                                Icons.hourglass_bottom,
                                color: Colors.blue,
                                size: MediaQuery.of(context).size.width * 0.15,
                              ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue),
                        Text(
                          isNotApproved
                              ? LocaleKeys.notApproved.tr()
                              : LocaleKeys.youraccountispendingverification
                                  .tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue),
                        Text(
                          isNotApproved
                              ? data.statusMessage ??
                                  LocaleKeys.youraccountisnotapproved.tr()
                              : LocaleKeys.youhavesubmittedyourdocuments.tr(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue),
                        isNotApproved
                            ? CustomButton(
                                text: LocaleKeys.submitagain.tr(),
                                onPressed: onPressedSubmitAgain,
                              )
                            : const SizedBox(),
                        const Divider(height: AppConstants.defaultNumericValue),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                          "${LocaleKeys.submittedat.tr()}${DateFormatter.toWholeDate(data.createdAt)}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      const SizedBox(
                          height: AppConstants.defaultNumericValue / 4),
                      Text(
                          "${LocaleKeys.lastUpdatedat.tr()}${DateFormatter.toWholeDate(data.updatedAt)}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}

class _NotVerifiedPart extends ConsumerStatefulWidget {
  final bool submitAgain;
  const _NotVerifiedPart({
    required this.submitAgain,
  });

  @override
  ConsumerState<_NotVerifiedPart> createState() => _NotVerifiedPartState();
}

class _NotVerifiedPartState extends ConsumerState<_NotVerifiedPart> {
  PickedFileModel? _photoIdFrontView;
  PickedFileModel? _photoIdBackView;
  PickedFileModel? _selfie;

  void _onSubmit() async {
    final verificationData = ref.read(verificationProvider);

    EasyLoading.show(status: LocaleKeys.uploading.tr());
    String? photoIdFrontPath =
        await _savePictures(_photoIdFrontView!, "photoIdFront");
    String? photoIdBackPath =
        await _savePictures(_photoIdBackView!, "photoIdBack");
    String? selfiePath = await _savePictures(_selfie!, "selfie");

    if (photoIdFrontPath == null ||
        photoIdBackPath == null ||
        selfiePath == null) {
      EasyLoading.showInfo(LocaleKeys.somethingWentWrong);
      return;
    } else {
      VerificationFormModel form = VerificationFormModel(
        id: ref.watch(currentUserStateProvider)!.phoneNumber!,
        phoneNumber: ref.watch(currentUserStateProvider)!.phoneNumber!,
        photoIdFrontViewUrl: photoIdFrontPath,
        photoIdBackViewUrl: photoIdBackPath,
        selfieUrl: selfiePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPending: true,
        isApproved: false,
      );
      if (widget.submitAgain) {
        await verificationData.updateVerificationForm(form);
      } else {
        await verificationData.submitVerificationForm(form);
      }
    }
  }

  Future<String?> _savePictures(PickedFileModel file, String title) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child(ref.watch(currentUserStateProvider)!.phoneNumber!)
        .child("Verification Pictures")
        .child(title);

    String? url;
    final SettableMetadata metadata = SettableMetadata(
        contentType: (file.fileName!.contains(".jpg") ||
                file.fileName!.contains(".jpeg"))
            ? 'image/jpeg'
            : 'image/png');

    UploadTask uploadTask =
        storageReference.putData(file.pickedFile!, metadata);
    await uploadTask.whenComplete(() async =>
        await storageReference.getDownloadURL().then((value) => url = value));
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(LocaleKeys.areyousuretodiscardverification.tr()),
              actions: [
                TextButton(
                  child: Text(LocaleKeys.yes.tr()),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text(LocaleKeys.no.tr()),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        body: 
        // !kIsWeb
        //     ? const ExampleWidget()
        //     : 
            Container(
                padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.submitdocuments.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                        height: AppConstants.defaultNumericValue / 2),
                    Text(
                      LocaleKeys.weneedtoverifyyourinformation.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                        height: AppConstants.defaultNumericValue * 4),
                    VerificationSingleStep(
                      leadingIcon: Icons.credit_card,
                      onTap: () async {
                        final List<PickedFileModel>? results =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoIdPage(
                              frontView: _photoIdFrontView,
                              backView: _photoIdBackView,
                            ),
                          ),
                        );
                        setState(() {
                          _photoIdFrontView = results?.first;
                          _photoIdBackView = results?.last;
                        });
                      },
                      title: LocaleKeys.photoID.tr(),
                      trailingIcon:
                          _photoIdFrontView != null && _photoIdBackView != null
                              ? Icons.check
                              : Icons.arrow_forward,
                    ),
                    const SizedBox(height: AppConstants.defaultNumericValue),
                    VerificationSingleStep(
                      leadingIcon: Icons.camera_alt,
                      onTap: () async {
                        final PickedFileModel? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfiePage(selfie: _selfie),
                          ),
                        );
                        setState(() {
                          _selfie = result;
                        });
                      },
                      title: LocaleKeys.takeaselfie.tr(),
                      trailingIcon:
                          _selfie != null ? Icons.check : Icons.arrow_forward,
                    ),
                    const SizedBox(
                        height: AppConstants.defaultNumericValue * 2),
                    _photoIdBackView != null &&
                            _photoIdFrontView != null &&
                            _selfie != null
                        ? CustomButton(
                            text: LocaleKeys.submit, onPressed: _onSubmit)
                        : const SizedBox(),
                  ],
                ),
              ),
      ),
    );
  }
}

class VerificationSingleStep extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData trailingIcon;
  final VoidCallback onTap;
  const VerificationSingleStep({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppConstants.primaryColor.withOpacity(.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(16),
      title: Text(title),
      leading: Icon(leadingIcon),
      trailing: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          child: Icon(trailingIcon)),
      onTap: onTap,
    );
  }
}

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  Image? imageToShow;
  late Logger logger;
  int counter = 0;
  bool imageLoading = false;

  bool get hasImage => imageToShow != null;
  bool get skipValidation => counter >= 3;

  @override
  void initState() {
    logger = Logger();
    super.initState();
  }

  void reset() {
    imageToShow = null;
    imageLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imageToShow != null) {
      return Scaffold(
        // appBar: AppBar(
        //     leading: IconButton(
        //   key: const Key('back_button'),
        //   icon: const Icon(
        //     Icons.arrow_back,
        //     color: Colors.green,
        //     size: 24,
        //   ),
        //   onPressed: () {},
        // )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 300,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 1,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: imageToShow ?? const SizedBox.shrink(),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Text(
                '¿Tu documento es legible?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Antes de avanzar, confirma que el documento se encuentre centrado, sin recortes y que todos los datos del se puedan leer correctamente.',
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 2.0, color: Colors.green),
                      ),
                      onPressed: reset,
                      child: const Text('Repetir foto',
                          style: TextStyle(color: Colors.green)))),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: () {},
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.white),
                ),
              )),
            ],
          ),
        ),
      );
    }

    return DocumentSelfieVerification(
        side: SideType.frontSide,
        country: CountryType.colombia,
        onTakePhoto: (File response, EmojiType? emoji) {
          imageToShow = Image.file(response);
          setState(() {});
        });
  }
}
