class SoundCategory {
  int? _soundCategoryId;
  String? _soundCategoryName;
  String? _soundCategoryProfile;
  List<SoundData>? _soundList;

  int? get soundCategoryId => _soundCategoryId;

  String? get soundCategoryName => _soundCategoryName;

  String? get soundCategoryProfile => _soundCategoryProfile;

  List<SoundData>? get soundList => _soundList;

  SoundCategory(
      {int? soundCategoryId,
      String? soundCategoryName,
      String? soundCategoryProfile,
      List<SoundData>? soundList}) {
    _soundCategoryId = soundCategoryId;
    _soundCategoryName = soundCategoryName;
    _soundCategoryProfile = soundCategoryProfile;
    _soundList = soundList;
  }

  SoundCategory.fromJson(dynamic json) {
    _soundCategoryId = json["sound_category_id"];
    _soundCategoryName = json["sound_category_name"];
    _soundCategoryProfile = json["sound_category_profile"];
    if (json["sound_list"] != null) {
      _soundList = [];
      json["sound_list"].forEach((v) {
        _soundList!.add(SoundData.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["sound_category_id"] = _soundCategoryId;
    map["sound_category_name"] = _soundCategoryName;
    map["sound_category_profile"] = _soundCategoryProfile;
    if (_soundList != null) {
      map["sound_list"] = _soundList!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SoundData {
  String? _soundId;
  int? _soundCategoryId;
  String? _soundTitle;
  String? _sound;
  String? _duration;
  String? _singer;
  String? _soundImage;
  String? _addedBy;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String? get soundId => _soundId;

  int? get soundCategoryId => _soundCategoryId;

  String? get soundTitle => _soundTitle;

  String? get sound => _sound;

  String? get duration => _duration;

  String? get singer => _singer;

  String? get soundImage => _soundImage;

  String? get addedBy => _addedBy;

  DateTime? get createdAt => _createdAt;

  DateTime? get updatedAt => _updatedAt;

  SoundData(
      {String? soundId,
      int? soundCategoryId,
      String? soundTitle,
      String? sound,
      String? duration,
      String? singer,
      String? soundImage,
      String? addedBy,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    _soundId = soundId;
    _soundCategoryId = soundCategoryId;
    _soundTitle = soundTitle;
    _sound = sound;
    _duration = duration;
    _singer = singer;
    _soundImage = soundImage;
    _addedBy = addedBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  SoundData.fromJson(dynamic json) {
    _soundId = json["soundId"];
    _soundCategoryId = json["soundCategoryId"];
    _soundTitle = json["soundTitle"];
    _sound = json["sound"];
    _duration = json["duration"];
    _singer = json["singer"];
    _soundImage = json["soundImage"];
    _addedBy = json["addedBy"];
    _createdAt = DateTime.fromMillisecondsSinceEpoch(json["createdAt"]);
    _updatedAt = DateTime.fromMillisecondsSinceEpoch(json["updatedAt"]);
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["soundId"] = _soundId;
    map["soundCategoryId"] = _soundCategoryId;
    map["soundTitle"] = _soundTitle;
    map["sound"] = _sound;
    map["duration"] = _duration;
    map["singer"] = _singer;
    map["soundImage"] = _soundImage;
    map["addedBy"] = _addedBy;
    map["createdAt"] = _createdAt!.millisecondsSinceEpoch;
    map["updatedAt"] = _updatedAt!.millisecondsSinceEpoch;
    return map;
  }
}
