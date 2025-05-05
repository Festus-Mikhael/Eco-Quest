import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
final String id;
final String name;
final String email;
final String avatarUrl;
final int points;
final List<dynamic> badges;

UserModel({
required this.id,
required this.name,
required this.email,
required this.avatarUrl,
this.points = 0,
this.badges = const [],
});

static UserModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
final data = doc.data()!;
return UserModel(
id: doc.id,
name: data['name'] ?? '',
email: data['email'] ?? '',
avatarUrl: data['avatarUrl'] ?? '',
points: data['points'] ?? 0,
badges: List<dynamic>.from(data['badges'] ?? []),
);
}

Map<String, dynamic> toMap() {
return {
'name': name,
'email': email,
'avatarUrl': avatarUrl,
'points': points,
'badges': badges,
};
}
}
