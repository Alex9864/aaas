import 'package:aaas/pages/auth/CreationEtudiant.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ProviderModel.dart';
import '../widgets/SelectionBox.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

  String _selectedBox = "";

  String selectedValue = "User";

  final _EmailFormKey = GlobalKey<FormState>();
  final TextEditingController _EmailTextFormFieldController = TextEditingController();

  final _FirstNameFormKey = GlobalKey<FormState>();
  final TextEditingController _FirstNameTextFormFieldController = TextEditingController();

  final _LastNameFormKey = GlobalKey<FormState>();
  final TextEditingController _LastNameTextFormFieldController = TextEditingController();

  final _PasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _PasswordTextFormFieldController = TextEditingController();
  bool _passwordVisible = false;

  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  final db = FirebaseFirestore.instance;

  final user = <String, dynamic>{
    "Role": "Debug",
    "FirstName": "FirstNameDebug",
    "LastName": "LastNameDebug",
    "ProfilePicture": "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
    "Interests": [],
    "Description": "",
    "School": "",
    "SchoolWanted": "",
    "CurrentLevel": "",
    "MentorUID": "",
    "MentoredUID": "",
    "UserMessageList": [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                Center(
                  child: Text(
                    "Créer un compte !",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
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
                SizedBox(height: 20,),
                Form(
                    key: _FirstNameFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _FirstNameTextFormFieldController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person_outline),
                        labelText: "Prénom",
                        hintText: 'Entrez votre prénom',
                      ),
                      keyboardType: TextInputType.text,
                      maxLength: 30,
                    )
                ),
                SizedBox(height: 20,),
                Form(
                    key: _LastNameFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _LastNameTextFormFieldController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person_outline),
                        labelText: "Nom",
                        hintText: 'Entrez votre nom',
                      ),
                      keyboardType: TextInputType.text,
                      maxLength: 30,
                    )
                ),
                SizedBox(height: 20,),
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
                SizedBox(height: 20,),
                Column(
                  children: [
                    Text(
                      "D'où venez vous ?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SelectionBox('assets/images/Corse.png', 'Corse', 'Corse' == _selectedBox, (value) {
                          setState(() {
                            _selectedBox = value;
                          });
                        }),
                        SizedBox(width: 10),
                        SelectionBox('assets/images/OpenCampusLogo.png', 'Open Campus', 'Open Campus' == _selectedBox, (value) {
                          setState(() {
                            _selectedBox = value;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                RoundedLoadingButton(
                  child: Text('Continuer', style: TextStyle(color: Colors.white)),
                  successColor: Colors.green,
                  controller: _verifyBtnController,
                  onPressed: () => _checkInfosAndContinue(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkInfosAndContinue() async {
    if (_EmailTextFormFieldController.text == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un e-mail"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_FirstNameTextFormFieldController.text == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un prénom"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_LastNameTextFormFieldController.text == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un nom"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_PasswordTextFormFieldController.text == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un mot de passe"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_selectedBox == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez selectionner d'où vous venez"),
          backgroundColor: Colors.red,
        ),
      );
    }
    else {
      String firstName = _FirstNameTextFormFieldController.text.trim();
      String lastName = _LastNameTextFormFieldController.text.trim();
      String email = _EmailTextFormFieldController.text.trim();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: _PasswordTextFormFieldController.text);
        user['FirstName'] = firstName;
        user['LastName'] = lastName;
        user['Email'] = email;
        user['uid'] = userCredential.user!.uid;
        if (_selectedBox == 'Corse') {
          user['Role'] = 'Etudiant';
          user['MentoredUID'] = userCredential.user!.uid;
        } else if (_selectedBox == 'Open Campus') {
          user['Role'] = 'Mentor';
          user['MentorUID'] = userCredential.user!.uid;
        }

        db.collection("users").doc(userCredential.user!.uid).set(user);

        final providerModel = Provider.of<ProviderModel>(context, listen: false);
        providerModel.setRole(user['Role']);
        providerModel.setFirstName(user['FirstName']);
        providerModel.setLastName(user['LastName']);
        providerModel.setEmail(user['Email']);
        providerModel.setUID(user['uid']);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreationEtudiantPage(role: user['Role'], name: user['FirstName'] + ' ' + user['LastName'])),
        );
      } catch(e){
        if (e is FirebaseAuthException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? ''),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    _verifyBtnController.stop();
  }
}