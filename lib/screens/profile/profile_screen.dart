import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/authMethods/auth_methods.dart';
import 'package:tiyatrokulubu/screens/home/home_page.dart';
import 'package:tiyatrokulubu/screens/instagramLayout/instagram_layout.dart';
import 'package:tiyatrokulubu/screens/profile/photo_zoom.dart';
import 'package:tiyatrokulubu/screens/utils/follow_button.dart';
import 'package:tiyatrokulubu/screens/utils/utils.dart';
import 'package:tiyatrokulubu/secureStorage/secure_storage.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String uid;

  ProfileScreen({Key? key, required this.uid});
  @override
  State<StatefulWidget> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  SecSto sto = SecSto();

  @override
  void initState() {
    super.initState();
    getData();
  }

//Profil sayfasında dataları getiren method.
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
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;

      setState(() {
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
          //Profil verilerinin üst kısmının gösterilmesi
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
                        ],
                      ),
                     //Eğer Kendi profilimize girirsek çıkış yap butonu ekrana geliyor ama diğer kullanıcılarda görünmüyor
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
                          : SizedBox(),
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
                //Profil verilerinde tarifelerin görünmesi
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

                                //   (snap.data()! as dynamic)['postUrl'],
                                // ,

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

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
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
