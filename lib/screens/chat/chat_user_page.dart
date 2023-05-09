import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/shared/widgets/message_textfield.dart';
import 'package:sparepark/shared/widgets/single_message.dart';

class ChatUserPage extends StatefulWidget {
  final String u_id;
  final String currentUserId;

  const ChatUserPage(
      {Key? key, required this.u_id, required this.currentUserId})
      : super(key: key);

  @override
  _ChatUserPageState createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  // User? _currentUser;
  String _otherUserName = '';
  String _otherUserImage = '';

  @override
  void initState() {
    super.initState();
    // Get the currently logged in user from Firebase
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   setState(() {
    //     _currentUser = user;
    //   });
    //   print('Currently logged in user: ${user?.uid}');
    //   print('Currently logged in user: ${user?.uid}');
    // });
    // Get the user's name and image from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.u_id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _otherUserName = documentSnapshot.get('name');
          _otherUserImage = documentSnapshot.get('image');
        });
      } else {
        print('User does not exist in the database');
      }
    }).catchError((error) {
      print('Error retrieving user data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentUserId);
    print(_otherUserName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              // child: CachedNetworkImage(
              //   imageUrl: _otherUserImage,
              //   placeholder: (conteext, url) => CircularProgressIndicator(),
              //   errorWidget: (context, url, error) => Icon(
              //     Icons.error,
              //   ),
              //   height: 40,
              // ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              _otherUserName,
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.currentUserId)
                      .collection('messages')
                      .doc(widget.u_id)
                      .collection('chats')
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length < 1) {
                        return Center(
                          child: Text("Say Hi"),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isMe = snapshot.data.docs[index]['senderId'] ==
                              widget.currentUserId;
                          DateTime date =
                              snapshot.data.docs[index]['date'].toDate();
                          String datetime =
                              DateFormat('MMM d, h:mm a').format(date);
                          String message = snapshot.data.docs[index]['message'];
                          return SingleMessage(
                            friendName: _otherUserName,
                            datetime: datetime,
                            message: message,
                            isMe: isMe,
                          );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
          ),
          if (widget.currentUserId != null || widget.u_id != null)
            Container(
              child: MessageTextField(
                widget.currentUserId,
                widget.u_id,
              ),
            ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   print(_currentUser?.uid);
  //   print(_otherUserName);
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.teal,
  //       title: Row(
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(80),
  //             child: CachedNetworkImage(
  //               imageUrl: _otherUserImage,
  //               placeholder: (conteext, url) => CircularProgressIndicator(),
  //               errorWidget: (context, url, error) => Icon(
  //                 Icons.error,
  //               ),
  //               height: 40,
  //             ),
  //           ),
  //           SizedBox(
  //             width: 5,
  //           ),
  //           Text(
  //             _otherUserName,
  //             style: TextStyle(fontSize: 20),
  //           )
  //         ],
  //       ),
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //             child: Container(
  //           padding: EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(25),
  //                   topRight: Radius.circular(25))),
  //           child: StreamBuilder(
  //               stream: FirebaseFirestore.instance
  //                   .collection("users")
  //                   .doc(_currentUser?.uid)
  //                   .collection('messages')
  //                   .doc(widget.u_id)
  //                   .collection('chats')
  //                   .orderBy("date", descending: true)
  //                   .snapshots(),
  //               builder: (context, AsyncSnapshot snapshot) {
  //                 if (snapshot.hasData) {
  //                   if (snapshot.data.docs.length < 1) {
  //                     return Center(
  //                       child: Text("Say Hi"),
  //                     );
  //                   }
  //                   return ListView.builder(
  //                     itemCount: snapshot.data.docs.length,
  //                     reverse: true,
  //                     physics: BouncingScrollPhysics(),
  //                     itemBuilder: (context, index) {
  //                       bool isMe = snapshot.data.docs[index]['senderId'] ==
  //                           _currentUser?.uid;
  //                       DateTime date =
  //                           snapshot.data.docs[index]['date'].toDate();
  //                       String datetime =
  //                           DateFormat('MMM d, h:mm a').format(date);
  //                       String message = snapshot.data.docs[index]['message'];
  //                       return SingleMessage(
  //                         friendName: _otherUserName,
  //                         datetime: datetime,
  //                         message: message,
  //                         isMe: isMe,
  //                       );
  //                     },
  //                   );
  //                 }
  //                 return Center(child: CircularProgressIndicator());
  //               }),
  //         )),
  //         MessageTextField(_currentUser!.uid, _otherUserName),
  //       ],
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('User Page'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text('User ID: ${widget.u_id}'),
  //           if (_user != null) Text('Logged in user: ${_user!.uid}'),
  //           Text('Name: $_userName'),
  //           Image.network(
  //             _userImage,
  //             loadingBuilder: (BuildContext context, Widget child,
  //                 ImageChunkEvent? loadingProgress) {
  //               if (loadingProgress == null) {
  //                 return child;
  //               }
  //               return Center(
  //                 child: CircularProgressIndicator(
  //                   value: loadingProgress.expectedTotalBytes != null
  //                       ? loadingProgress.cumulativeBytesLoaded /
  //                           loadingProgress.expectedTotalBytes!
  //                       : null,
  //                 ),
  //               );
  //             },
  //             errorBuilder:
  //                 (BuildContext context, Object error, StackTrace? stackTrace) {
  //               return Text('Error loading image');
  //             },
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
