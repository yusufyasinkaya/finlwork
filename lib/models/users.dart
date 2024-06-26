import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final List followers;
  final List following;
  final String bio;
  final int userType;
  const User(
      {required this.email,
      required this.uid,
      required this.photoUrl,
      required this.username,
      required this.followers,
      required this.following,
      required this.bio,
      required this.userType});
  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "followers": followers,
        "bio": bio,
        "following": following,
        "userType": userType
      };
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
        username: snapshot['username'],
        uid: snapshot['uid'],
        email: snapshot['email'],
        photoUrl: snapshot['photoUrl'],
        followers: snapshot['followers'],
        bio: snapshot['bio'],
        userType: snapshot['userType'],
        following: snapshot['following']);
  }
}
