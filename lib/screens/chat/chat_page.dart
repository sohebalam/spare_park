import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/shared/style/contstants.dart';
import 'package:sparepark/shared/widgets/message_textfield.dart';
import 'package:sparepark/shared/widgets/single_message.dart';

class ChatPage extends StatefulWidget {
  final String u_id;
  final String currentUserId;

  const ChatPage({Key? key, required this.u_id, required this.currentUserId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // User? _currentUser;
  String _otherUserName = '';
  String _otherUserImage = '';

  @override
  void initState() {
    super.initState();

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

    // Load the Firebase image after a delay of 1 second
    Future.delayed(Duration(seconds: 1), () {
      if (_otherUserImage.isNotEmpty) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentUserId);
    print(_otherUserName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants().primaryColor,
        title: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: _otherUserImage.isNotEmpty
                      ? Image.network(
                          _otherUserImage,
                          height: 30,
                        )
                      : Image.asset(
                          'assets/person.png', // replace with your local image path
                          height: 30,
                        ),
                ),
                if (_otherUserImage.isEmpty)
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('date',
                        descending: !(widget.currentUserId == widget.u_id))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot message = snapshot.data!.docs[index];
                      String datetime = DateFormat('MMM d, h:mm a')
                          .format(message['date'].toDate());
                      bool isCurrentUser =
                          (message['senderId'] == widget.currentUserId);
                      return SingleMessage(
                        friendName: _otherUserName,
                        datetime: datetime,
                        message: message['message'],
                        isMe: isCurrentUser,
                      );
                      // return ListTile(
                      //   title: Text(
                      //     message['message'],
                      //     textAlign:
                      //         isCurrentUser ? TextAlign.right : TextAlign.left,
                      //   ),
                      //   subtitle: Text(
                      //     message['date'].toDate().toString(),
                      //     textAlign:
                      //         isCurrentUser ? TextAlign.right : TextAlign.left,
                      //   ),
                      // );
                    },
                  );
                },
              ),
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
}
