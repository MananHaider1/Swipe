import 'package:flutterwave_standard/utils.dart';

class Customization {
  String? title;
  String? description;
  String? logo;

  Customization({this.title, this.description, this.logo});

  /// Converts instance of Customization to json
  Map<String, dynamic> toJson() {
    final customization = {
      "title": this.title != null ? this.title : "",
      "description": this.description != null ? this.description : "",
      "logo": this.logo != null ? this.logo : ""
    };
    return Utils.removeKeysWithEmptyValues(customization);
  }
}