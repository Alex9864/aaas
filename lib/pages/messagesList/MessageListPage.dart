import 'package:aaas/pages/messages/MessagesPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/MentorCard.dart';

class MessageListPage extends StatefulWidget {
  MessageListPage({Key? key}) : super(key: key);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                final currentUserUID = _firebaseAuth.currentUser!.uid;

                return ListView(
                  children: snapshot.data!.docs
                      .where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    final userMessageList = userData['UserMessageList'] as List<dynamic>;
                    return userMessageList.contains(currentUserUID);
                  })
                      .map<Widget>((doc) => _buildUserListItem(doc))
                      .toList(),
                );
              },
            ),
          )
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_firebaseAuth.currentUser!.email != data['Email']) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor, // Couleur de fond du container
          borderRadius: BorderRadius.circular(10), // Facultatif : bord arrondi
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data['ProfilePicture']),
            ),
            title: Text(data['FirstName'] + ' ' + data['LastName']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesPage(
                    receiverUserName: data['FirstName'] + ' ' + data['LastName'],
                    receiverUserId: data['uid'],
                    receiverUserAvatar: data['ProfilePicture'],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(); // Ou tout autre widget vide selon votre besoin
    }
  }
}
