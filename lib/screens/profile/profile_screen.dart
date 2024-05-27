import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tiyatrokulubu/authMethods/auth_methods.dart';
import 'package:tiyatrokulubu/firestroeMethods/firestroe_meethods.dart';
import 'package:tiyatrokulubu/screens/chat/view/chat_view.dart';
import 'package:tiyatrokulubu/screens/home/home_page.dart';
import 'package:tiyatrokulubu/screens/instagramLayout/instagram_layout.dart';
import 'package:tiyatrokulubu/screens/profile/photo_zoom.dart';
import 'package:tiyatrokulubu/screens/utils/follow_button.dart';
import 'package:tiyatrokulubu/screens/utils/utils.dart';
import 'package:tiyatrokulubu/secureStorage/secure_storage.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String uid;

  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  double averageRating = 0.0;
  bool isFollowing = false;
  bool isLoading = false;
  bool hasRated = false;
  double userRating = 0.0;
  SecSto sto = SecSto();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      var ratingSnap = await FirebaseFirestore.instance
          .collection('ratings')
          .doc(widget.uid)
          .get();

      setState(() {
        postLen = postSnap.docs.length;
        userData = userSnap.data()!;
        followers = userData['followers'].length;
        following = userData['following'].length;
        averageRating =
            ratingSnap.exists ? ratingSnap.data()!['averageRating'] : 0.0;

        if (ratingSnap.exists) {
          List ratings = ratingSnap.data()!['ratings'];
          var userRatingEntry = ratings.firstWhere(
              (r) => r['raterUid'] == FirebaseAuth.instance.currentUser!.uid,
              orElse: () => null);
          if (userRatingEntry != null) {
            userRating = userRatingEntry['rating'];
            hasRated = true;
          }
        }

        isFollowing = userData['followers']
            .contains(FirebaseAuth.instance.currentUser!.uid);
        isLoading = true;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LayoutScreen())),
                child: Icon(Icons.arrow_back_ios_new),
              ),
              backgroundColor: Colors.white,
              title: Text(
                userData['username'],
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(userData['photoUrl']),
                        radius: 40,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStatColumn(postLen, 'İlan Tarifesi'),
                          buildStatColumn(followers, 'Takipçi'),
                          if (FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid)
                            buildStatColumn(following, 'Takip Edilen'),
                          buildStatColumn(averageRating, 'Ortalama Puan'),
                        ],
                      ),
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? FollowButton(
                              text: 'Çıkış yap',
                              backgroundColor: Colors.white,
                              textcolor: Colors.black,
                              borderColor: Colors.grey,
                              function: () async {
                                await AuthMethods().signOut();
                                sto.deleteData();

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ));
                              },
                            )
                          : Column(
                              children: [
                                FollowButton(
                                  text:
                                      isFollowing ? 'Takipten Çık' : 'Takip Et',
                                  backgroundColor:
                                      isFollowing ? Colors.white : Colors.blue,
                                  textcolor:
                                      isFollowing ? Colors.black : Colors.white,
                                  borderColor:
                                      isFollowing ? Colors.grey : Colors.blue,
                                  function: () async {
                                    await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      widget.uid,
                                    );

                                    setState(() {
                                      isFollowing = !isFollowing;
                                      followers += isFollowing ? 1 : -1;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        double? rating =
                                            await showDialog<double>(
                                          context: context,
                                          builder: (context) => RatingDialog(
                                            initialRating: userRating,
                                          ),
                                        );

                                        if (rating != null) {
                                          double? newAverageRating =
                                              await FirestoreMethods().rateUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.uid,
                                            rating,
                                          );

                                          if (newAverageRating != null) {
                                            setState(() {
                                              averageRating = newAverageRating;
                                              userRating = rating;
                                              hasRated = true;
                                            });
                                          }
                                        }
                                      },
                                      child: Text('Puanla'),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    ElevatedButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatView(
                                                    receiverUserEmail:
                                                        userData["email"],
                                                    receiverUserId:
                                                        widget.uid))),
                                        child: Text("Mesaj")),
                                  ],
                                )
                              ],
                            ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 1),
                        child: Text(userData['bio']),
                      )
                    ],
                  ),
                ),
                Divider(),
                SingleChildScrollView(
                  reverse: true,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Center(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot snap =
                                  (snapshot.data! as dynamic).docs[index];
                              return Container(
                                  child: InkWell(
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: '${snap['description']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 20)),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                ),
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => PhotoZoom(
                                    snap: (snap.data()! as dynamic),
                                  ),
                                )),
                              ));
                            },
                          ),
                        );
                      }),
                )
              ],
            ),
          );
  }

  Column buildStatColumn(num value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        )
      ],
    );
  }
}

class RatingDialog extends StatefulWidget {
  final double initialRating;

  RatingDialog({required this.initialRating});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Puan Ver'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Puanınızı seçin:'),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (newRating) {
              setState(() {
                rating = newRating;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(rating);
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}
