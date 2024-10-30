import 'dart:io';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AliasForm extends StatefulWidget {
  final Map<String, dynamic> user;
  final DataModel? model;
  final SharedPreferences prefs;
  const AliasForm(this.user, this.model, this.prefs, {super.key});

  @override
  AliasFormState createState() => AliasFormState();
}

class AliasFormState extends State<AliasForm> {
  TextEditingController? _alias;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _alias = TextEditingController(text: Lamat.getNickname(widget.user));
  }

  Future getImage(File image) {
    setState(() {
      _imageFile = image;
    });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    String? name = Lamat.getNickname(widget.user);
    return AlertDialog(
      backgroundColor: Teme.isDarktheme(widget.prefs)
          ? AppConstants.dialogColorDark
          : AppConstants.backgroundColor,
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            onPressed: widget.user[Dbkeys.aliasName] != null ||
                    widget.user[Dbkeys.aliasAvatar] != null
                ? () {
                    widget.model!.removeAlias(widget.user[Dbkeys.phone]);
                    Navigator.pop(context);
                  }
                : null,
            child: Text(
              "Remove Alias",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
              ),
            )),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              "Set Alias",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor),
            ),
            onPressed: () {
              if (_alias!.text.isNotEmpty) {
                if (_alias!.text != name || _imageFile != null) {
                  widget.model!.setAlias(
                      _alias!.text, _imageFile, widget.user[Dbkeys.phone]);
                }
                Navigator.pop(context);
              }
            })
      ],
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              width: 120,
              height: 120,
              child: Stack(children: [
                Center(
                    child: Lamat.avatar(widget.user,
                        image: _imageFile, radius: 50)),
              ])),
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            controller: _alias,
            style: TextStyle(
              color: pickTextColorBasedOnBgColorAdvanced(
                  Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor),
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(widget.prefs)
                            ? AppConstants.dialogColorDark
                            : AppConstants.backgroundColor)
                    .withOpacity(0.6),
              ),
              hintText: "Alias Name",
            ),
            validator: (val) {
              if (val!.trim().isEmpty) return "Name cannot be empty!";
              return null;
            },
          )
        ]),
      ),
    );
  }
}
