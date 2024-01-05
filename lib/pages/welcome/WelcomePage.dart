import 'package:aaas/pages/BottomNavigationBar/BottomNavigationBar.dart';
import 'package:aaas/pages/auth/AuthenticationPage.dart';
import 'package:aaas/pages/auth/ConnexionPage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_theme/json_theme.dart';

import 'package:provider/provider.dart';
import '../../ProviderModel.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  final db = FirebaseFirestore.instance;

  final RoundedLoadingButtonController _getStartedBtnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _haveAnAccountBtnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              getUserInfos();
              return BottomNavigationBarPage();
            } else {
              return SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo2.png',
                            height: 300,
                          ),
                          SizedBox(height: 30),
                          Text("Bienvenue dans Spérienzha !",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 25
                            ),),
                          SizedBox(height: 10),
                          Text("Connectons nous d'abord à ton compte !",
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 15
                            ),),
                          SizedBox(height: 30),
                          RoundedLoadingButton(
                            child: Text(
                                'Créer un compte', style: TextStyle(color: Colors
                                .white)),
                            successColor: Colors.green,
                            controller: _getStartedBtnController,
                            onPressed: () => _onClickGetStartedButton(),
                          ),
                          SizedBox(height: 30),
                          RoundedLoadingButton(
                            child: Text("J'ai déjà un compte",
                                style: TextStyle(color: Colors.white)),
                            //color: ColorSchemeSchema(AlertDialog),
                            controller: _haveAnAccountBtnController,
                            onPressed: _onClickAlreadyHaveAnAccountButton,
                          ),
                        ],
                      ),
                    ),
                  )
              );
            }
          }
      ),
    );
  }

  void getUserInfos(){
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference _docRef = db.collection('users').doc(user.uid);

    _docRef.get().then((DocumentSnapshot docSnap) {
      if (docSnap.exists) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        String FirstName = data['FirstName'];
        String ProfilePicture = data['ProfilePicture'];
        changeUser(FirstName, ProfilePicture);
      } else {
        // Handle the case where the document does not exist
      }
    });
  }

  void changeUser(String FirstName, String ProfilePicture) {
    final providerModel = Provider.of<ProviderModel>(context, listen: false);
    providerModel.setFirstName(FirstName);
    providerModel.setProfilePicture(ProfilePicture);
  }

  void _onClickGetStartedButton(){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const AuthenticationPage()
        )
    );
    _getStartedBtnController.stop();
  }

  void _onClickAlreadyHaveAnAccountButton(){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const ConnexionPage()
        )
    );
    _haveAnAccountBtnController.stop();
  }

}
