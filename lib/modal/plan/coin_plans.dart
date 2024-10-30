class CoinPlans {
  List<CoinPlanData>? _data;

  List<CoinPlanData>? get data => _data;

  CoinPlans({List<CoinPlanData>? data}) {
    _data = data;
  }

  CoinPlans.fromJson(dynamic json) {
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data!.add(CoinPlanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_data != null) {
      map["data"] = _data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class CoinPlanData {
  int? _coinPlanId;
  String? _coinPlanName;
  String? _coinPlanDescription;
  double? _coinPlanPrice;
  int? _coinAmount;
  String? _playstoreProductId;
  String? _appstoreProductId;
  int? _createdAt;
  int? _updatedAt;

  int? get coinPlanId => _coinPlanId;

  String? get coinPlanName => _coinPlanName;

  String? get coinPlanDescription => _coinPlanDescription;

  double? get coinPlanPrice => _coinPlanPrice;

  int? get coinAmount => _coinAmount;

  String? get playstoreProductId => _playstoreProductId;

  String? get appstoreProductId => _appstoreProductId;

  int? get createdAt => _createdAt;

  int? get updatedAt => _updatedAt;

  CoinPlanData(
      {int? coinPlanId,
      String? coinPlanName,
      String? coinPlanDescription,
      double? coinPlanPrice,
      int? coinAmount,
      String? playstoreProductId,
      String? appstoreProductId,
      int? createdAt,
      int? updatedAt}) {
    _coinPlanId = coinPlanId;
    _coinPlanName = coinPlanName;
    _coinPlanDescription = coinPlanDescription;
    _coinPlanPrice = coinPlanPrice;
    _coinAmount = coinAmount;
    _playstoreProductId = playstoreProductId;
    _appstoreProductId = appstoreProductId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  CoinPlanData.fromJson(dynamic json) {
    _coinPlanId = json["coin_plan_id"];
    _coinPlanName = json["coin_plan_name"];
    _coinPlanDescription = json["coin_plan_description"];
    _coinPlanPrice = json["coin_plan_price"];
    _coinAmount = json["coin_amount"];
    _playstoreProductId = json["playstore_product_id"];
    _appstoreProductId = json["appstore_product_id"];
    _createdAt = json["created_at"];
    _updatedAt = json["updated_at"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["coin_plan_id"] = _coinPlanId;
    map["coin_plan_name"] = _coinPlanName;
    map["coin_plan_description"] = _coinPlanDescription;
    map["coin_plan_price"] = _coinPlanPrice;
    map["coin_amount"] = _coinAmount;
    map["playstore_product_id"] = _playstoreProductId;
    map["appstore_product_id"] = _appstoreProductId;
    map["created_at"] = _createdAt;
    map["updated_at"] = _updatedAt;
    return map;
  }
}
