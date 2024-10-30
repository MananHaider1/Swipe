import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenSettings extends StatefulWidget {
  final String? permtype;
  final SharedPreferences? prefs;
  const OpenSettings({
    super.key,
    this.permtype = 'other',
    this.prefs,
  });
  @override
  State<OpenSettings> createState() => _OpenSettingsState();
}

class _OpenSettingsState extends State<OpenSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Lamat.getNTPWrappedWidget(Material(
        color: AppConstants.primaryColor,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.contact_page,
              color: Colors.white60,
              size: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                widget.permtype == 'contact'
                    ? "Allow Contact Access"
                    : "We respect your decission. But neccessary Permission needed so that app can work. If you still wish to Allow Permission, you may follow these steps:",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                widget.permtype == 'contact'
                    ? "$Appname app requires Contacts access to show you Friends available to Chat & Call with.  "
                    : "1. Open App Settings.\n\n2. Go to Permissions.\n\n3.Allow permission for the required service.\n\n4. Return to app & reload the page.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: myElevatedButton(
                    color: AppConstants.secondaryColor,
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Manage Permission",
                        style: TextStyle(color: AppConstants.lamatWhite),
                      ),
                    ))),
            if (widget.permtype == 'contact')
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20),
                  child: myElevatedButton(
                      color: AppConstants.lamatWhite,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          // the route
                          MaterialPageRoute(
                            builder: (BuildContext context) => const MyApp(),
                          ),

                          (Route route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Back",
                          style: TextStyle(color: AppConstants.lamatBlack),
                        ),
                      ))),
            const SizedBox(height: 20),
            if (widget.permtype == 'contact')
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "If you do not wish to allow Contact permission, you may uninstall the app ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
          ],
        ))));
  }
}
