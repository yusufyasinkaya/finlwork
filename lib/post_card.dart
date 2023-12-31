import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tiyatrokulubu/firestroeMethods/firestroe_meethods.dart';
import 'package:tiyatrokulubu/models/providers/user_provider.dart';
import 'package:tiyatrokulubu/screens/comment/comment_screen.dart';
import 'package:tiyatrokulubu/screens/utils/utils.dart';

class Postcard extends StatefulWidget {
  final snap;

  Postcard({Key? key, required this.snap}) : super(key: key);

  @override
  State createState() => _PostcardState();
}

class _PostcardState extends State<Postcard> {
  bool isAnimating = false;
  int commentLen = 0;
  @override
  initState() {
    super.initState();
    getComments();
  }
//Yorumları çekiyoruz
  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<UserProvider>(context);
    if (viewmodel.user == null) {
      return Center(
        child: Text(""),
      );
    } else
      return Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        /*Verilerin düzeni */
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ).copyWith(right: 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.10),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(widget.snap['profileImage']),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.snap['username'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                      child: ListView(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shrinkWrap: true,
                                        children: [
                                          'Delete',
                                        ]
                                            .map((e) => InkWell(
                                                  onTap: () async {
                                                    FirestoreMethods()
                                                        .deletePost(widget
                                                            .snap['postId']);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                    child: Text(e),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ));
                          },
                          icon: Icon(Icons.more_vert))
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 8),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                          text: '${widget.snap['description']}',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 20))
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onDoubleTap: () async {
                await FirestoreMethods().likePost(widget.snap['postId'],
                    viewmodel.getUser.uid, widget.snap['likes']);
                setState(() {
                  isAnimating = true;
                });
                await Future.delayed(Duration(milliseconds: 400));
                setState(() {
                  isAnimating = false;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          widget.snap['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      )),
                  // AnimatedOpacity(
                  //     duration: Duration(milliseconds: 200),
                  //     opacity: isAnimating ? 1 : 0,
                  //     child: LikeAnimations(
                  //       child: Icon(
                  //         Icons.favorite,
                  //         color: Colors.white,
                  //         size: 100,
                  //       ),
                  //       isAnimating: isAnimating,
                  //       duration: Duration(milliseconds: 400),
                  //       /*onEnd:(){

                  //           setState((){
                  //             isAnimating = false;
                  //           });*/

                  //       //       }
                  //     )),
                ],
              ),
            ),
            Row(
              children: [
                // LikeAnimations(
                //     isAnimating:
                //         widget.snap['likes'].contains(viewmodel.getUser.uid),
                //     child: IconButton(
                //         onPressed: () async {
                //           await FirestoreMethods().likePost(
                //               widget.snap['postId'],
                //               viewmodel.getUser.uid,
                //               widget.snap['likes']);
                //         },
                //         icon:
                //             widget.snap['likes'].contains(viewmodel.getUser.uid)
                //                 ? Icon(
                //                     Icons.favorite,
                //                     color: Colors.red,
                //                   )
                //                 : Icon(Icons.favorite_border))),
                IconButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentScreen(
                                  snap: widget.snap['postId'],
                                ))),
                    icon: Icon(
                      Icons.comment_outlined,
                    )),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommentScreen(
                          snap: widget.snap['postId'],
                        ))),
                child: Container(
                  padding: EdgeInsets.only(bottom: 3, left: 12, top: 3),
                  alignment: Alignment.topLeft,
                  child: Text(
                    "$commentLen yorum yapılmış. Görmek için tıklayın",
                    style: TextStyle(fontSize: 16, color: Colors.black26),
                  ),
                )),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                DateFormat.yMMMd().format(
                  widget.snap['datePublished'].toDate(),
                ),
                style: TextStyle(fontSize: 12, color: Colors.black26),
              ),
            ),
            Divider(
              thickness: 5,
              color: Colors.white.withOpacity(0.5),
            )
          ],
        ),
      );
  }
}
