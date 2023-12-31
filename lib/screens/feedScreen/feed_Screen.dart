import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/post_card.dart';
import 'package:tiyatrokulubu/screens/feedScreen/cstom_image.dart';

class FeedScreen extends StatefulWidget {
  @override
  State createState() => _FeedScreen();
}

class _FeedScreen extends State {
  Image appLogo = new Image(
    image: new ExactAssetImage("assets/images/AppLogo.png"),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("EACESS"),
        elevation: 0,
        centerTitle: true,
      ),
      /* İlanların anasayfaya çekilmesini sağlıyoruz. Verileri düzenli göstermek için PostCard isimli classtan verilerin dizilimi ayarlandıS */
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
