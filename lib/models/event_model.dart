import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:lamatdating/models/user_interaction_model.dart';

class EventsModel {
  final String name;
  final String image;
  final bool isActive;
  final int startDate;
  final int endDate;
  final List<String> users; // Assuming user IDs are stored as strings
  final List<UserInteractionModel> userInteractions;

  EventsModel({
    required this.name,
    required this.image,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.users,
    required this.userInteractions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'isActive': isActive,
      'startDate': startDate,
      'endDate': endDate,
      'users': users,
      'userInteractions': userInteractions,
    };
  }

  factory EventsModel.fromMap(Map<String, dynamic> map) {
    return EventsModel(
      name: map['name'] as String,
      image: map['image'] as String,
      isActive: map['isActive'] as bool,
      startDate: map['startDate'] as int,
      endDate: map['endDate'] as int,
      users: (map['users'] as List)
          .cast<String>(), // Handle null or cast to String
      userInteractions: List<UserInteractionModel>.from(
        map['userInteractions']?.map((x) => UserInteractionModel.fromMap(x)),
      ),
    );
  }
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'EventsModel(name: $name, image: $image, isActive: $isActive, startDate: $startDate, endDate: $endDate, users: $users, userInteractions: $userInteractions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
    return other is EventsModel &&
        other.name == name &&
        other.image == image &&
        other.isActive == isActive &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        listEquals(other.users, users) &&
        listEquals(other.userInteractions, userInteractions);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        image.hashCode ^
        isActive.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        users.hashCode ^
        userInteractions.hashCode;
  }
}
