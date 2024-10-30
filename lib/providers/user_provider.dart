import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:flutter/widgets.dart';

final userProviderProvider =
    ChangeNotifierProvider<UserProvider>((ref) => UserProvider());

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get getUser => _user;

  getUserDetails(String? phone) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(phone)
        .get();

    _user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }
}

class UserModel {
  String? uid;
  String? name;
  String? phone;
  String? username;
  String? status;
  int? state;
  String? profilePhoto;

  UserModel({
    this.uid,
    this.name,
    this.phone,
    this.username,
    this.status,
    this.state,
    this.profilePhoto,
  });

  Map toMap(UserModel user) {
    var data = <String, dynamic>{};
    data['id'] = user.uid;
    data['nickname'] = user.name;
    data['phone'] = user.phone;
    data["photoUrl"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  UserModel.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['id'];
    name = mapData['nickname'];
    phone = mapData['phone'];
    profilePhoto = mapData['photoUrl'];
  }
}
