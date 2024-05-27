import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiyatrokulubu/storageMethods/storage_method.dart';
import 'package:uuid/uuid.dart';

import '../models/post/post.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String profileImage,
    String username,
  ) async {
    String res = "Hata alındı";
    try {
      String photoUrl = await StorageMethods().uploadImage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profileImage: profileImage,
          likes: []);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "Succes";
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postRating(String uid, double rating, String comment,
      String raterUid, String raterUsername, String raterPhotoUrl) async {
    try {
      var ratingRef = _firestore.collection('ratings').doc(uid);

      DocumentSnapshot doc = await ratingRef.get();

      if (doc.exists) {
        List ratings = (doc.data() as Map<String, dynamic>)['ratings'];
        ratings.add({
          'raterUid': raterUid,
          'raterUsername': raterUsername,
          'raterPhotoUrl': raterPhotoUrl,
          'rating': rating,
          'comment': comment,
          'datePublished': DateTime.now(),
        });

        double averageRating =
            ratings.map((r) => r['rating']).reduce((a, b) => a + b) /
                ratings.length;

        await ratingRef.update({
          'ratings': ratings,
          'averageRating': averageRating,
        });
      } else {
        await ratingRef.set({
          'uid': uid,
          'ratings': [
            {
              'raterUid': raterUid,
              'raterUsername': raterUsername,
              'raterPhotoUrl': raterPhotoUrl,
              'rating': rating,
              'comment': comment,
              'datePublished': DateTime.now(),
            }
          ],
          'averageRating': rating,
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print("Text yok");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<double?> rateUser(
      String uid, String ratedUserId, double rating) async {
    try {
      var ratingRef = _firestore.collection('ratings').doc(ratedUserId);
      DocumentSnapshot doc = await ratingRef.get();

      double newAverageRating;

      if (doc.exists) {
        List ratings = (doc.data() as Map<String, dynamic>)['ratings'];

        bool hasRated = ratings.any((r) => r['raterUid'] == uid);

        if (hasRated) {
          for (var r in ratings) {
            if (r['raterUid'] == uid) {
              r['rating'] = rating;
              r['datePublished'] = DateTime.now();
              break;
            }
          }
        } else {
          ratings.add({
            'raterUid': uid,
            'rating': rating,
            'datePublished': DateTime.now(),
          });
        }

        newAverageRating =
            ratings.map((r) => r['rating']).reduce((a, b) => a + b) /
                ratings.length;

        await ratingRef.update({
          'ratings': ratings,
          'averageRating': newAverageRating,
        });

        return newAverageRating;
      } else {
        newAverageRating = rating;

        await ratingRef.set({
          'uid': ratedUserId,
          'ratings': [
            {
              'raterUid': uid,
              'rating': rating,
              'datePublished': DateTime.now(),
            }
          ],
          'averageRating': newAverageRating,
        });

        return newAverageRating;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
