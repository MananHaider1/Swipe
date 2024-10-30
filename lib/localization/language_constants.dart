// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String VIETNAMESE = 'vi';
const String ARABIC = 'ar';
const String HINDI = 'hi';
const String GERMAN = 'de';
const String SPANISH = 'es';
const String FRENCH = 'fr';
const String INDONESIAN = 'id';
const String JAPANESE = 'ja';
const String KOREAN = 'ko';
const String TURKISH = 'tr';
const String CHINESE = 'zh';
const String CHINESE_TRADITIONAL = 'zh_HK';
const String DUTCH = 'nl';
const String BANGLA = 'bn';
const String PORTUGUESE = 'pt';
const String URDU = 'ur';
const String SWAHILI = 'sw';
const String RUSSIAN = 'ru';
const String PERSIAN = 'fa';
const String MALAY = 'ms';
const String GEORGIAN = 'ka';
const String THAI = 'th';

List languagelist = [
  ENGLISH,
  BANGLA,
  ARABIC,
  HINDI,
  GERMAN,
  SPANISH,
  FRENCH,
  INDONESIAN,
  JAPANESE,
  KOREAN,
  TURKISH,
  CHINESE,
  CHINESE_TRADITIONAL,
  VIETNAMESE,
  DUTCH,
  URDU,
  PORTUGUESE,
  SWAHILI,
  RUSSIAN,
  PERSIAN,
  MALAY,
  GEORGIAN,
  THAI
];
List<Locale> supportedlocale = [
  const Locale(ENGLISH, "US"),
  const Locale(ARABIC, "SA"),
  const Locale(HINDI, "IN"),
  const Locale(BANGLA, "BD"),
  const Locale(GERMAN, "DE"),
  const Locale(SPANISH, "ES"),
  const Locale(FRENCH, "FR"),
  const Locale(INDONESIAN, "ID"),
  const Locale(JAPANESE, "JP"),
  const Locale(KOREAN, "KR"),
  const Locale(TURKISH, "TR"),
  const Locale(CHINESE, "CN"),
  const Locale('zh', "HK"),
  const Locale(VIETNAMESE, 'VN'),
  const Locale(DUTCH, 'NZ'),
  const Locale(URDU, 'PK'),
  const Locale(PORTUGUESE, 'PT'),
  const Locale(SWAHILI, 'KE'),
  const Locale(RUSSIAN, 'RU'),
  const Locale(PERSIAN, 'IR'),
  const Locale(MALAY, 'MY'),
  const Locale(GEORGIAN, 'GE'),
  const Locale(THAI, 'TH'),
];

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode =
      prefs.getString(LAGUAGE_CODE) ?? DEFAULT_LANGUAGE_FILE_CODE;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case BANGLA:
      return const Locale(BANGLA, 'BD');
    case VIETNAMESE:
      return const Locale(VIETNAMESE, "VN");
    case ARABIC:
      return const Locale(ARABIC, "SA");
    case HINDI:
      return const Locale(HINDI, "IN");
    case GERMAN:
      return const Locale(GERMAN, "DE");
    case SPANISH:
      return const Locale(SPANISH, "ES");
    case FRENCH:
      return const Locale(FRENCH, "FR");
    case INDONESIAN:
      return const Locale(INDONESIAN, "ID");
    case JAPANESE:
      return const Locale(JAPANESE, "JP");
    case KOREAN:
      return const Locale(KOREAN, "KR");
    case TURKISH:
      return const Locale(TURKISH, "TR");
    case DUTCH:
      return const Locale(DUTCH, "NZ");
    case CHINESE:
      return const Locale(CHINESE, "CN");
    case CHINESE_TRADITIONAL:
      return const Locale(CHINESE, "HK");
    case URDU:
      return const Locale(URDU, 'PK');
    case PORTUGUESE:
      return const Locale(PORTUGUESE, 'PT');
    case SWAHILI:
      return const Locale(SWAHILI, 'KE');
    case RUSSIAN:
      return const Locale(RUSSIAN, 'RU');

    case PERSIAN:
      return const Locale(PERSIAN, 'IR');
    case MALAY:
      return const Locale(MALAY, 'MY');
    case GEORGIAN:
      return const Locale(GEORGIAN, 'GE');
    case THAI:
      return const Locale(THAI, 'TH');

    default:
      return const Locale(ENGLISH, 'US');
  }
}

// String getTranslated(BuildContext context, String key) {
//   return DemoLocalization.of(context)!.translate(key) ?? '';
// }
