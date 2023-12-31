import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/screens/instagramLayout/instagram_layout.dart';
import 'package:tiyatrokulubu/screens/profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final docUser = FirebaseFirestore.instance.collection('users');
  final docPost = FirebaseFirestore.instance.collection('posts');

  bool isShowUser = false;
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*Kayıtlı kullanıcıları firebase sorgusu yaparak arama sayfası */
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => LayoutScreen())),
            child: Icon(Icons.arrow_back_ios_new),
          ),
          backgroundColor: Colors.white,
          title: TextFormField(
            controller: searchController,
            decoration: InputDecoration(labelText: 'Bir Kullanıcı Arayın'),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUser = true;
              });
            },
          ),
        ),
        body: Column(
          children: [
            Text("Önerilen Kullanıcılar"),
            Expanded(
              child: Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: docUser
                      .where('username',
                          isGreaterThanOrEqualTo: searchController.text)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          uid: (snapshot.data! as dynamic)
                                              .docs[index]['uid']))),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      (snapshot.data! as dynamic).docs[index]
                                              ['photoUrl'] ??
                                          ''),
                                ),
                                title: Text((snapshot.data! as dynamic)
                                        .docs[index]['username'] ??
                                    ''),
                              ),
                            );
                          });
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
