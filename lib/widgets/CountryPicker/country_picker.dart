import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'country.dart';
export 'country.dart';

/// The country picker widget exposes an dialog to select a country from a
/// pre defined list, see [Country.ALL]
class CountryPicker extends StatelessWidget {
  const CountryPicker({
    super.key,
    this.selectedCountry,
    required this.onChanged,
    this.dense = false,
  });

  final Country? selectedCountry;
  final ValueChanged<Country> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    Country? displayCountry = selectedCountry;

    displayCountry ??=
        Country.findByIsoCode(Localizations.localeOf(context).countryCode);

    return dense
        ? _renderDenseDisplay(context, displayCountry!)
        : _renderDefaultDisplay(context, displayCountry!);
  }

  _renderDefaultDisplay(BuildContext context, Country displayCountry) {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            displayCountry.asset,
            package: null,
            height: 48.0,
            fit: BoxFit.fitWidth,
          ),
          Text(" (+${displayCountry.dialingCode})"),
          Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70),
        ],
      ),
      onTap: () {
        _selectCountry(context, displayCountry);
      },
    );
  }

  _renderDenseDisplay(BuildContext context, Country displayCountry) {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            displayCountry.asset,
            package: null,
            height: 24.0,
            fit: BoxFit.fitWidth,
          ),
          Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70),
        ],
      ),
      onTap: () {
        _selectCountry(context, displayCountry);
      },
    );
  }

  Future<void> _selectCountry(
      BuildContext context, Country defaultCountry) async {
    final Country? picked = await showCountryPicker(
      context: context,
      defaultCountry: defaultCountry,
    );

    if (picked != null && picked != selectedCountry) onChanged(picked);
  }
}

/// Display an [Dialog] with the country list to selection
/// you can pass and [defaultCountry], see [Country.findByIsoCode]
Future<Country?> showCountryPicker({
  required BuildContext context,
  required Country defaultCountry,
}) async {
  assert(Country.findByIsoCode(defaultCountry.isoCode) != null);

  return await showDialog<Country>(
    context: context,
    builder: (BuildContext context) => _CountryPickerDialog(
      defaultCountry: defaultCountry,
    ),
  );
}

class _CountryPickerDialog extends StatefulWidget {
  const _CountryPickerDialog({
    Country? defaultCountry,
  });

  @override
  State<StatefulWidget> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  TextEditingController controller = TextEditingController();
  String? filter;
  late List<Country> countries;

  @override
  void initState() {
    super.initState();

    countries = Country.ALL;

    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Dialog(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: LocaleKeys.search.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter == null || filter == ""
                    ? const SizedBox(
                        height: 0.0,
                        width: 0.0,
                      )
                    : InkWell(
                        child: const Icon(Icons.clear),
                        onTap: () {
                          controller.clear();
                        },
                      ),
              ),
              controller: controller,
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (BuildContext context, int index) {
                    Country country = countries[index];
                    if (filter == null ||
                        filter == "" ||
                        country.name
                            .toLowerCase()
                            .contains(filter!.toLowerCase()) ||
                        country.isoCode.contains(filter!)) {
                      return InkWell(
                        child: ListTile(
                          trailing: Text("+${country.dialingCode}"),
                          title: Row(
                            children: <Widget>[
                              Image.asset(
                                country.asset,
                                package: null,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    country.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, country);
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
