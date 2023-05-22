import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/screens/chat/chat_page.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

// class ChatList extends StatelessWidget {
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Messages List'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('messages').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           // Group messages by receiverId
//           Map<String, List<DocumentSnapshot>> conversations = {};
//           List<DocumentSnapshot> messages = snapshot.data!.docs;
//           for (DocumentSnapshot message in messages) {
//             String receiverId = message['receiverId'];
//             if (!conversations.containsKey(receiverId)) {
//               conversations[receiverId] = [];
//             }
//             conversations[receiverId]!.add(message);
//           }

//           // Build conversation list
//           List<Widget> conversationList = conversations.keys.map((receiverId) {
//             List<DocumentSnapshot> conversationMessages =
//                 conversations[receiverId]!;
//             DocumentSnapshot lastMessage = conversationMessages.last;

//             return ListTile(
//               title: Text(receiverId),
//               subtitle: Text(lastMessage['message']),

//               onTap: () {
//                 // Navigate to the conversation page with the given receiverId
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatPage(
//                       currentUserId: receiverId,
//                       u_id: currentUser!.uid,
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList();

//           return ListView(
//             children: conversationList,
//           );
//         },
//       ),
//     );
//   }
// }
class ChatList extends StatelessWidget {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Conversations', isLoggedInStream: isLoggedInStream),
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

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(receiverId)
                  .get(),
              builder:
                  (context, AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                if (asyncSnapshot.hasData) {
                  var friend =
                      asyncSnapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: CachedNetworkImage(
                        imageUrl: friend['image'] as String,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                        ),
                        height: 50,
                      ),
                    ),
                    title: Text(friend['name'] as String),
                    subtitle: Container(
                      child: Text(
                        lastMessage['message'] as String,
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
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
                } else if (asyncSnapshot.hasError) {
                  return ListTile(
                    title: Text('Error loading data'),
                  );
                } else {
                  return ListTile(
                    title: Text('Loading...'),
                  );
                }
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
