// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// import 'package:sparepark/screens/auth/auth_screen.dart';
// import 'package:sparepark/screens/chat/chat_page.dart';
// import 'package:sparepark/services/auth_service.dart';
// import 'package:sparepark/shared/widgets/app_bar.dart';
// // import 'package:sparepark/chat_screen.dart';
// // import 'package:sparepark/models/user_model.dart';

// class ChatList extends StatefulWidget {
//   @override
//   _ChatListState createState() => _ChatListState();
// }

// class _ChatListState extends State<ChatList> {
//   late User? currentUser;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Get the current user when the widget is first created
//     currentUser = FirebaseAuth.instance.currentUser;
//   }

//   Future<void> getMessageCount() async {
//     print("Finding messages for current user");

//     if (currentUser == null) {
//       print("Current user is null");
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(currentUser!.uid)
//         .collection("messages")
//         .doc(currentUser!.uid)
//         .collection("chats")
//         .get();

//     List<String> messages = [];
//     snapshot.docs.forEach((doc) {
//       messages.add(doc['message']);
//     });

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final isLoggedInStream = authService.user!.map((user) => user != null);
//     return Scaffold(
//       appBar: CustomAppBar(
//           title: 'Conversations', isLoggedInStream: isLoggedInStream),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser!.uid)
//             .collection('messages')
//             .snapshots(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (isLoading) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (snapshot.hasData) {
//             if (snapshot.data.docs.length < 1) {
//               return Center(
//                 child: Text("No Chats Available !"),
//               );
//             }
//             return ListView.builder(
//               itemCount: snapshot.data.docs.length,
//               itemBuilder: (context, index) {
//                 var friendId = snapshot.data.docs[index].id;
//                 var lastMsg = snapshot.data.docs[index]['last_msg'];
//                 return FutureBuilder(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(friendId)
//                       .get(),
//                   builder: (context, AsyncSnapshot asyncSnapshot) {
//                     if (asyncSnapshot.hasData) {
//                       var friend = asyncSnapshot.data;
//                       return ListTile(
//                         leading: ClipRRect(
//                           borderRadius: BorderRadius.circular(80),
//                           child: CachedNetworkImage(
//                             imageUrl: friend['image'],
//                             placeholder: (context, url) =>
//                                 CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Icon(
//                               Icons.error,
//                             ),
//                             height: 50,
//                           ),
//                         ),
//                         title: Text(friend['name']),
//                         subtitle: Container(
//                           child: Text(
//                             "$lastMsg",
//                             style: TextStyle(color: Colors.grey),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChatPage(
//                                 u_id: friend.id,
//                                 currentUserId: currentUser!.uid,
//                                 // friend: User.fromSnapshot(friend),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return Container();
//                     }
//                   },
//                 );
//               },
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparepark/screens/chat/chat_page.dart';

class ChatList extends StatelessWidget {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Group messages by receiverId
          Map<String, List<DocumentSnapshot>> conversations = {};
          List<DocumentSnapshot> messages = snapshot.data!.docs;
          for (DocumentSnapshot message in messages) {
            String receiverId = message['receiverId'];
            if (!conversations.containsKey(receiverId)) {
              conversations[receiverId] = [];
            }
            conversations[receiverId]!.add(message);
          }

          // Build conversation list
          List<Widget> conversationList = conversations.keys.map((receiverId) {
            List<DocumentSnapshot> conversationMessages =
                conversations[receiverId]!;
            DocumentSnapshot lastMessage = conversationMessages.last;

            return ListTile(
              title: Text(receiverId),
              subtitle: Text(lastMessage['message']),
              onTap: () {
                // Navigate to the conversation page with the given receiverId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserId: receiverId,
                      u_id: currentUser!.uid,
                    ),
                  ),
                );
              },
            );
          }).toList();

          return ListView(
            children: conversationList,
          );
        },
      ),
    );
  }
}

class ConversationPage extends StatelessWidget {
  final String receiverId;

  const ConversationPage({required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation with $receiverId'),
      ),
      body: Center(
        child: Text('Conversation content here'),
      ),
    );
  }
}
