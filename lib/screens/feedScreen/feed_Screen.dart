import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/post_card.dart';
import 'package:tiyatrokulubu/screens/chat/view/messages.dart';
import 'package:tiyatrokulubu/screens/feedScreen/cstom_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class FeedScreen extends StatefulWidget {
  @override
  State createState() => _FeedScreen();
}

class _FeedScreen extends State<FeedScreen> {
  Image appLogo = Image(
    image: ExactAssetImage("assets/images/AppLogo.png"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("EACESS"),
        elevation: 0,
        centerTitle: true,
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('chats')
                .where('unread', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }
              return IconButton(
                icon: badges.Badge(
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  showBadge: unreadCount > 0,
                  child: Icon(Icons.message),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChattedUsersListPage(
                          userId: FirebaseAuth.instance.currentUser!.uid),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomBackgroundImage(),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Postcard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
