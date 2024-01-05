import 'package:aaas/pages/messages/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../widgets/PopupProfile.dart';

class MessagesPage extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserId;
  final String receiverUserAvatar;
  const MessagesPage({super.key, required this.receiverUserName, required this.receiverUserAvatar, required this.receiverUserId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo_bg_long.png',
              color: Color.fromRGBO(0, 0, 0, 0.02),
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).secondaryHeaderColor
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return PopupProfile(userUID: widget.receiverUserId);
                                    },
                                  );
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  child: ClipOval(
                                    child: Image.network(
                                      widget.receiverUserAvatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // En cas d'erreur de chargement de l'image, afficher l'image par défaut
                                        return Image.network(
                                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Text(widget.receiverUserName, style: TextStyle(fontSize: 20),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildMessageList(),
                  ),
                  _buildMessageInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error' + snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return FutureBuilder<String>(
      future: _toDate(data['timestamp']),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..."); // Vous pouvez afficher un indicateur de chargement pendant que la date se charge
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Column(
            children: [
              SizedBox(height: 12,),
              Container(
                alignment: alignment,
                child: Column(
                  crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(snapshot.data ?? ''), // Utilisez la valeur de la date résolue ici
                    SizedBox(height: 2,),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Color.fromRGBO(43, 186, 216, 1) : Theme.of(context).colorScheme.secondary
                      ),
                      child: Text(
                        data['message'],
                        style: TextStyle(color: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }


  Future<String> _toDate(Timestamp timestamp) async {
    await initializeDateFormatting('fr_FR', null);
    DateTime timestampToDate = DateTime.parse(timestamp.toDate().toString());

    // Ajouter une heure à l'heure récupérée pour corriger le décalage
    timestampToDate = timestampToDate.add(Duration(hours: 1));

    String formattedDate = DateFormat('EEEE d MMMM : HH:mm', 'fr_FR').format(timestampToDate);

    // Mettre la première lettre du jour en majuscule
    formattedDate = formattedDate.replaceFirst(formattedDate[0], formattedDate[0].toUpperCase());

    return formattedDate;
  }


  Widget _buildMessageInput() {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt_outlined, size: 25,)),
        SizedBox(width: 5,),
        Expanded(child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(

              decoration: InputDecoration(
                hintText: "Envoyer un message",
                border: InputBorder.none
              ),
              controller: _messageController,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              minLines: 1,
            ),
          ),
        ),),
        IconButton(onPressed: sendMessage, icon: Icon(Icons.play_arrow_outlined, size: 40,))
      ],
    );
  }
}
