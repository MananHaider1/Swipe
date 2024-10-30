import 'dart:convert';

// import 'package:collection/collection.dart';
// import 'package:flutter/foundation.dart';

class GoalModel {
  String streamTitle;
  int streamGoal;
  String streamGoalType;
  String goalDescription;

  GoalModel(
      {required this.streamTitle,
      required this.streamGoal,
      required this.streamGoalType,
      required this.goalDescription});

  GoalModel copyWith({
    String? streamTitle,
    int? streamGoal,
    String? streamGoalType,
    String? goalDescription,
  }) {
    return GoalModel(
        streamTitle: streamTitle ?? this.streamTitle,
        streamGoal: streamGoal ?? this.streamGoal,
        streamGoalType: streamGoalType ?? this.streamGoalType,
        goalDescription: goalDescription ?? this.goalDescription);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'streamTitle': streamTitle,
      'streamGoal': streamGoal,
      'streamGoalType': streamGoalType,
      'goalDescription': goalDescription
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      streamTitle: map['streamTitle'] ?? '',
      streamGoal: map['streamGoal']?.toInt() ?? 0,
      streamGoalType: map['streamGoalType'] ?? '',
      goalDescription: map['goalDescription'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalModel.fromJson(String source) =>
      GoalModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GoalModel(streamTitle: $streamTitle, streamGoal: $streamGoal, streamGoalType: $streamGoalType, goalDescription: $goalDescription)';
  }

  @override
  bool operator ==(covariant GoalModel other) {
    if (identical(this, other)) return true;
    // final listEquals = const DeepCollectionEquality().equals;

    return other.streamTitle == streamTitle &&
        other.streamGoal == streamGoal &&
        other.streamGoalType == streamGoalType &&
        other.goalDescription == goalDescription;
  }

  @override
  int get hashCode {
    return streamTitle.hashCode ^
        streamGoal.hashCode ^
        streamGoalType.hashCode ^
        goalDescription.hashCode;
  }
}
