import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final _EmailFormKey = GlobalKey<FormState>();
  final TextEditingController _EmailTextFormFieldController = TextEditingController();

  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  final db = FirebaseFirestore.instance;

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
                          Text("Entrez votre email.\nNous vous enverrons un lien afin de reinitialiser votre mot de passe.",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 23,
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
                                    ? 'Entrez un email valide'
                                    : null,
                                controller: _EmailTextFormFieldController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email_outlined),
                                  labelText: "Email",
                                  hintText: 'Entrez votre email',
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: 30,
                              )
                          ),
                          SizedBox(height: 30),
                          RoundedLoadingButton(
                            child: Text('Envoyer le lien', style: TextStyle(color: Colors.white)),
                            successColor: Colors.green,
                            controller: _verifyBtnController,
                            onPressed: () => _resetPassword(),
                          ),
                        ]
                    )
                )
            )
        )
    );
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference _docRef = db.collection('users').doc(user.email!);

    _docRef.get().then((DocumentSnapshot docSnap) async {
      if (docSnap.exists) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _EmailTextFormFieldController.text);
        _verifyBtnController.stop();
      }
    });
  }
}
