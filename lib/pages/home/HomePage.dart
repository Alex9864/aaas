import 'package:aaas/pages/widgets/MentorCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/PopupProfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    "Trouvez le Mentor qui vous accompagnera !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30,),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      // Filtrer les utilisateurs avec le rôle "Mentor"
                      List<Map<String, dynamic>> mentors = snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        return {
                          'documentId': document.id,
                          ...data,
                        };
                      })
                          .where((user) => user['Role'] == 'Mentor') // Filtrer les mentors uniquement
                          .toList();

                      return LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: mentors.map((mentor) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return PopupProfile(userUID: mentor['uid']);
                                          },
                                        );
                                      },
                                      child: MentorCard(
                                        image: mentor['ProfilePicture'],
                                        name: mentor['FirstName'] + " " + mentor['LastName'],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
