import 'package:aaas/pages/BottomNavigationBar/BottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../ProviderModel.dart';
import 'ForgotPasswordPage.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({Key? key}) : super(key: key);

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {

  final _EmailFormKey = GlobalKey<FormState>();
  final TextEditingController _EmailTextFormFieldController = TextEditingController();

  final _PasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _PasswordTextFormFieldController = TextEditingController();
  bool _passwordVisible = false;

  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            getUserInfos();
            return BottomNavigationBarPage();
          } else {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Connectez vous à votre compte",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      Form(
                          key: _EmailFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Entrez un e-mail valide'
                                : null,
                            controller: _EmailTextFormFieldController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.email_outlined),
                              labelText: "Email",
                              hintText: 'Entrez votre e-mail',
                            ),
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                          )
                      ),
                      SizedBox(height: 10),
                      Form(
                          key: _PasswordFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: _PasswordTextFormFieldController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock_open),
                              labelText: "Mot de passe",
                              hintText: 'Entrez votre mot de passe',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                          )
                      ),
                      SizedBox(height: 30),
                      RoundedLoadingButton(
                        child: Text('Se connecter', style: TextStyle(color: Colors.white)),
                        successColor: Colors.green,
                        controller: _verifyBtnController,
                        onPressed: () => _signIn(),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordPage()
                                )
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _EmailTextFormFieldController.text,
          password: _PasswordTextFormFieldController.text
      );
      getUserInfos();
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Les informations données sont mauvaises ou expirées."),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Votre mot de passe est incorrect."),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Aucun utilisateur trouvé pour cet e-mail."),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Une erreur s\'est produite lors de la connexion."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Une erreur s\'est produite lors de la connexion."),
            backgroundColor: Colors.red,
          ),
        );
      }
  } finally {
      _verifyBtnController.stop();
    }
  }

  void getUserInfos(){
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference _docRef = db.collection('users').doc(user.uid!);

    _docRef.get().then((DocumentSnapshot docSnap) {
      if (docSnap.exists) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        String firstName = data['FirstName'];
        String lastName = data['LastName'];
        String role = data['Role'];
        String profilePicture = data['ProfilePicture'];
        changeUser(profilePicture, role, firstName, lastName, user.email.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Il n'existe aucun utilisateur avec cet email"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void changeUser(String ProfilePicture, String Role, String FirstName, String LastName, String Email) {
    final model = Provider.of<ProviderModel>(context, listen: false);
    model.setProfilePicture(ProfilePicture);
    model.setRole(Role);
    model.setFirstName(FirstName);
    model.setLastName(LastName);
    model.setEmail(Email);
  }

}

