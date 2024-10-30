// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/get_location_prediction.dart';
import 'package:lamatdating/models/location_prediction_model.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/providers/country_codes_provider.dart';
import 'package:lamatdating/providers/get_current_location_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

class SetUserLocation extends ConsumerStatefulWidget {
  final SharedPreferences? prefs;
  const SetUserLocation({super.key, this.prefs});

  @override
  ConsumerState<SetUserLocation> createState() => _SetUserLocationState();
}

class _SetUserLocationState extends ConsumerState<SetUserLocation> {
  final _searchController = TextEditingController();

  final List<Prediction> _predictions = [];

  @override
  void initState() {
    _searchController.addListener(() async {
      if (_searchController.text.isNotEmpty &&
          _searchController.text.length > 2) {
        final results =
            await getLocationPrediction(_searchController.text.trim());
        if (results != null) {
          _predictions.clear();
          _predictions.addAll(results);
        }
      } else {
        _predictions.clear();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationProviderProvider =
        ref.watch(getCurrentLocationProviderProvider);

    final countryCodesData = ref.watch(countryCodesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(LocaleKeys.setLocation.tr()),
        titleTextStyle: TextStyle(
            color: widget.prefs != null
                ? Teme.isDarktheme(widget.prefs!)
                    ? Colors.white
                    : Colors.black
                : AppConstants.primaryColor),
        leading: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultNumericValue),
          child: CustomAppBar(
            leading: CustomIconButton(
                padding: const EdgeInsets.all(
                    AppConstants.defaultNumericValue / 1.8),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: AppConstants.primaryColor,
                icon: closeIcon),
          ),
        ),
      ),
      body: countryCodesData.when(
          data: (data) {
            return currentLocationProviderProvider.when(
                data: (location) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (location != null)
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop(location);
                            },
                            title: Text(LocaleKeys.currentLocation.tr()),
                            subtitle: Text(location.addressText),
                            leading: const Icon(Icons.location_on),
                            minLeadingWidth: 0,
                          ),
                        if (location != null) const Divider(height: 0),
                        if (location != null)
                          Padding(
                            padding: const EdgeInsets.all(
                                AppConstants.defaultNumericValue),
                            child: Text(
                              LocaleKeys.orFindanotherlocation.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (location == null)
                          const SizedBox(
                              height: AppConstants.defaultNumericValue),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.searchforalocation.tr(),
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      AppConstants.defaultNumericValue),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_predictions.isEmpty &&
                            _searchController.text.isNotEmpty)
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(LocaleKeys.noresultsfound.tr()),
                            ),
                          ),
                        if (_predictions.isEmpty &&
                            _searchController.text.isEmpty)
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(LocaleKeys.findalocation.tr()),
                            ),
                          ),
                        ..._predictions.map(
                          (e) {
                            return e.description != null
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          EasyLoading.show(
                                              status: LocaleKeys.plswait.tr());

                                          await getLocationFromPlaceID(
                                                  e.placeId!)
                                              .then((value) {
                                            if (value != null) {
                                              final userLocation = UserLocation(
                                                addressText: e.description!,
                                                latitude: value.lat,
                                                longitude: value.long,
                                              );
                                              EasyLoading.dismiss();

                                              Navigator.of(context)
                                                  .pop(userLocation);
                                            } else {
                                              EasyLoading.dismiss();
                                              Navigator.of(context).pop();
                                            }
                                          });
                                        },
                                        title: Text(e.description!),
                                      ),
                                      const Divider(height: 0),
                                    ],
                                  )
                                : const SizedBox();
                          },
                        )
                      ],
                    ),
                  );
                },
                error: (_, e) {
                  return const ErrorPage();
                },
                loading: () => const LoadingPage());
          },
          error: (_, e) {
            return const ErrorPage();
          },
          loading: () => const LoadingPage()),
    );
  }
}

Future<LocationComponents?> getLocationFromPlaceID(String placeId) async {
  final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$locationApiKey");

  var response = await http.get(url, headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    var data = json.decode(response.body);

    if (data["status"] != "OK") {
      return null;
    } else {
      double? lat = data["result"]["geometry"]["location"]["lat"];
      double? long = data["result"]["geometry"]["location"]["lng"];

      if (lat != null && long != null) {
        return LocationComponents(lat: lat, long: long);
      }
    }
  } else {
    return null;
  }
  return null;
}

class LocationComponents {
  double lat;
  double long;
  LocationComponents({
    required this.lat,
    required this.long,
  });
}
