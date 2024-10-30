import 'dart:convert';
import 'package:collection/collection.dart';

class MeetingModel {
  String id;
  String status;
  String host;
  String invitee;
  DateTime createdAt;
  int budget;
  DateTime meetingDate;
  String meetingStartTime;
  String meetingEndTime;
  String meetingVenue;
  String? description;
  List<String> images;
  MeetingModel({
    required this.id,
    required this.status,
    required this.host,
    required this.invitee,
    required this.createdAt,
    required this.budget,
    required this.meetingDate,
    required this.meetingStartTime,
    required this.meetingEndTime,
    required this.meetingVenue,
    this.description,
    required this.images,
  });

  MeetingModel copyWith({
    String? id,
    String? status,
    String? host,
    String? invitee,
    DateTime? createdAt,
    int? budget,
    DateTime? meetingDate,
    String? meetingStartTime,
    String? meetingEndTime,
    String? meetingVenue,
    String? description,
    List<String>? images,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      status: status ?? this.status,
      host: host ?? this.host,
      invitee: invitee ?? this.invitee,
      createdAt: createdAt ?? this.createdAt,
      budget: budget ?? this.budget,
      meetingDate: meetingDate ?? this.meetingDate,
      meetingStartTime: meetingStartTime ?? this.meetingStartTime,
      meetingEndTime: meetingEndTime ?? this.meetingEndTime,
      meetingVenue: meetingVenue ?? this.meetingVenue,
      description: description ?? this.description,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'status': status});
    result.addAll({'host': host});
    result.addAll({'invitee': invitee});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'budget': budget});
    result.addAll({'meetingDate': meetingDate.millisecondsSinceEpoch});
    result.addAll({'meetingStartTime': meetingStartTime});
    result.addAll({'meetingEndTime': meetingEndTime});
    result.addAll({'meetingVenue': meetingVenue});
    if (description != null) {
      result.addAll({'description': description});
    }
    result.addAll({'images': images});

    return result;
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: map['id'] ?? '',
      status: map['status'] ?? '',
      host: map['host'] ?? '',
      invitee: map['invitee'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      budget: map['budget']?.toInt() ?? 0,
      meetingDate: DateTime.fromMillisecondsSinceEpoch(map['meetingDate']),
      meetingStartTime: map['meetingStartTime'],
      meetingEndTime: map['meetingEndTime'],
      meetingVenue: map['meetingVenue'],
      description: map['description'],
      images: List<String>.from(map['images']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MeetingModel.fromJson(String source) =>
      MeetingModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MeetingModel(id: $id, status: $status, host: $host, invitee: $invitee, meetingStartTime: $meetingStartTime, meetingEndTime: $meetingEndTime, meetingVenue: $meetingVenue, createdAt: $createdAt, budget: $budget, meetingDate: $meetingDate, description: $description, images: $images,)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is MeetingModel &&
        other.id == id &&
        other.status == status &&
        other.host == host &&
        other.invitee == invitee &&
        other.meetingStartTime == meetingStartTime &&
        other.meetingEndTime == meetingEndTime &&
        other.meetingVenue == meetingVenue &&
        other.createdAt == createdAt &&
        other.budget == budget &&
        other.meetingDate == meetingDate &&
        other.description == description &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        status.hashCode ^
        host.hashCode ^
        invitee.hashCode ^
        meetingStartTime.hashCode ^
        meetingEndTime.hashCode ^
        meetingVenue.hashCode ^
        createdAt.hashCode ^
        budget.hashCode ^
        meetingDate.hashCode ^
        description.hashCode ^
        images.hashCode;
  }
}
