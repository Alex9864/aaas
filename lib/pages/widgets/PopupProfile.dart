import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../messages/MessagesPage.dart';

class PopupProfile extends StatelessWidget {
  final String userUID;

  const PopupProfile({
    Key? key,
    required this.userUID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userUID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Une erreur s'est produite : ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text("Aucune donnée trouvée pour cet utilisateur");
        }

        // Récupérer les données de l'utilisateur depuis le document Firestore
        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

        // Utilisez les données récupérées pour afficher dans votre AlertDialog
        return AlertDialog(
          title: Text("Profil de ${userData['FirstName']} ${userData['LastName']}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userData['ProfilePicture'] != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(userData['ProfilePicture']),
                    radius: 50,
                  ),
                SizedBox(height: 10),
                Text(
                  "Description :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromRGBO(43, 186, 216, 1)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      userData['Description'] ?? "Pas de description disponible",
                      style: TextStyle(
                        fontSize: 15,
                      )
                    ),
                  )
                ),
                SizedBox(height: 20),
                Text(
                  "École : ${userData['School'] ?? 'Non renseigné'}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
                ),
                SizedBox(height: 20,),
                Text(
                  "Niveau d'étude actuel : ${userData['CurrentLevel'] ?? 'Non renseigné'}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
                ),
                SizedBox(height: 20),
                Text(
                  "Centres d'intérêt :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
                _buildInterestChips(userData['Interests']),
                SizedBox(height: 30,),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _contact(),
                    child: Text("Contacter"),
                  ),
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  void _contact() {
    // Récupérer l'uid de l'utilisateur actuellement connecté
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    String currentUserUID = _firebaseAuth.currentUser!.uid;

    // Mettre à jour le champ "UserMessageList" du document utilisateur actuellement connecté
    FirebaseFirestore.instance.collection('users').doc(currentUserUID).update({
      'UserMessageList': FieldValue.arrayUnion([userUID]),
    }).then((_) {
      // Succès de la mise à jour
      print('Identifiant ajouté avec succès à la liste des messages de l\'utilisateur connecté.');
      // Ajouter ici la logique pour naviguer vers la page de messages si nécessaire
    }).catchError((error) {
      // Gestion des erreurs
      print('Erreur lors de l\'ajout de l\'identifiant à la liste des messages : $error');
      // Ajouter ici une logique de gestion d'erreur si nécessaire
    });
  }


  Widget _buildInterestChips(dynamic interests) {
    if (interests != null && interests is List) {
      List<String> interestsList = List<String>.from(interests);
      if (interestsList.isNotEmpty) {
        return Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: interestsList.map<Widget>((interest) {
            return Chip(
              label: Text(interest),
            );
          }).toList(),
        );
      } else {
        return Text("Pas d'intérêts renseignés");
      }
    } else {
      return Text("Pas d'intérêts renseignés");
    }
  }
}