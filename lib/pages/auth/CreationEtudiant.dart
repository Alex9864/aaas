import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../ProviderModel.dart';
import '../BottomNavigationBar/BottomNavigationBar.dart';
import '../widgets/SelectionBox.dart';

class CreationEtudiantPage extends StatefulWidget {
  final String role;
  final String name;

  const CreationEtudiantPage({Key? key, required this.role, required this.name}) : super(key: key);

  @override
  State<CreationEtudiantPage> createState() => _CreationEtudiantPageState();
}

class _CreationEtudiantPageState extends State<CreationEtudiantPage> {

  final db = FirebaseFirestore.instance;
  final user = <String, dynamic>{
    "ProfilePicture": "",
    "Description": "",
    "Interests": [],
    "SchoolWanted": "",
    "CurrentLevel": "",
  };

  final List<String> levels = ['Choisir un niveau', 'Bac + 2', 'Bac + 3', 'Master 1'];
  bool _isLevelValid = false;
  String _selectedLevel = 'Choisir un niveau';

  bool _areTagsValid = false;
  List<String> _tags = [];
  List<String> _selectedTags = [];

  String _selectedBox = "";

  String _imageUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  final TextEditingController _descriptionTextFormFieldController = TextEditingController();

  final _profilePictureTextFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _profilePictureTextFormFieldController = TextEditingController();

  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

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
                  Text(
                    "Finalizez votre compte !",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 130,
                    height: 130,
                    child: ClipOval(
                      child: Image.network(
                        _imageUrl,
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
                  SizedBox(height: 20),
                  Text(widget.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 2, 2, 5),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Votre description",
                            border: InputBorder.none
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        controller: _descriptionTextFormFieldController,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _profilePictureTextFieldFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _profilePictureTextFormFieldController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.image),
                        labelText: "L'URL de votre image de profil",
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Centres d'interêt",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSelectedTags(), // Show selected tags on the main page
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showTagsPopup(context),
                    child: Text("Choisir vos centres d'Interêt"),
                  ),
                  SizedBox(height: 40),
                  if (widget.role == 'Etudiant') ...[
                    Text(
                      "Quel est ton niveau d'étude ?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10,),
                    DropdownButton<String>(
                      value: _selectedLevel,
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                          _isLevelValid = _selectedLevel != 'Choisir un niveau';
                        });
                      },
                      items: levels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30,),
                    Text(
                      "Quelle école veux-tu rejoindre ?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SelectionBox('assets/images/Supdemod.png', 'Sup de Mod', 'Sup de Mod' == _selectedBox, (value) {
                              setState(() {
                                _selectedBox = value;
                              });
                            }),
                            SizedBox(width: 10),
                            SelectionBox('assets/images/Supimmo.png', 'Sup Immo', 'Sup Immo' == _selectedBox, (value) {
                              setState(() {
                                _selectedBox = value;
                              });
                            }),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SelectionBox('assets/images/SSB.png', 'School of Sport Business', 'School of Sport Business' == _selectedBox, (value) {
                              setState(() {
                                _selectedBox = value;
                              });
                            }),
                            SizedBox(width: 10),
                            SelectionBox('assets/images/IFAG.png', 'IFAG', 'IFAG' == _selectedBox, (value) {
                              setState(() {
                                _selectedBox = value;
                              });
                            }),
                          ],
                        ),
                        SizedBox(height: 10,),
                        SelectionBox('assets/images/questionmark.png', 'Je ne sais pas', 'Je ne sais pas' == _selectedBox, (value) {
                          setState(() {
                            _selectedBox = value;
                          });
                        }),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ] else ...[
                    Container()
                  ],
                  SizedBox(height: 30),
                  RoundedLoadingButton(
                    child: Text('Créer votre compte', style: TextStyle(color: Colors.white)),
                    successColor: Colors.green,
                    controller: _verifyBtnController,
                    onPressed: () => _createAccount(),
                  ),
                  SizedBox(height: 30,)
                ],
              ),
            ),
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _descriptionTextFormFieldController.addListener(_onNameTextFieldChanged);
    _profilePictureTextFormFieldController.addListener(_onProfilePictureTextFieldChanged);
  }

  @override
  void dispose() {
    _descriptionTextFormFieldController.removeListener(_onNameTextFieldChanged);
    _profilePictureTextFormFieldController.removeListener(_onProfilePictureTextFieldChanged);
    _descriptionTextFormFieldController.dispose();
    _profilePictureTextFormFieldController.dispose();
    super.dispose();
  }

  void _onNameTextFieldChanged() {
    setState(() {});
  }

  void _onProfilePictureTextFieldChanged() {
    setState(() {
      _imageUrl = _profilePictureTextFormFieldController.text.isNotEmpty
          ? _profilePictureTextFormFieldController.text
          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
    });
  }

  void _createAccount() async {
    if (_selectedBox == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez selectionner un choix d'école"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_isLevelValid == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez selectionner un niveau d'étude"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_areTagsValid == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez selectionner au moins un centre d'interêt"),
          backgroundColor: Colors.red,
        ),
      );
    } else {

      // Mettre à jour le champ 'Description'
      user['Description'] = _descriptionTextFormFieldController.text.isNotEmpty
          ? _descriptionTextFormFieldController.text
          : "Votre description";

      // Mettre à jour le champ 'ProfilePicture' en utilisant l'URL actuel ou l'URL par défaut si nécessaire
      final imageUrl = _profilePictureTextFormFieldController.text.isNotEmpty
          ? _profilePictureTextFormFieldController.text
          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

      // Vérifier si l'image peut être chargée depuis l'URL
      final stream = Image.network(imageUrl).image.resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener((imageInfo, synchronousCall) {
        setState(() {
          // Si l'image peut être chargée, mettre à jour l'URL actuelle
          _imageUrl = imageUrl;
        });
      }, onError: (exception, stackTrace) {
        // Si l'image ne peut pas être chargée, utiliser l'URL par défaut
        setState(() {
          _imageUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
        });
      }));

      user['ProfilePicture'] = _imageUrl;
      user["SchoolWanted"] = _selectedBox;
      user["CurrentLevel"] = _selectedLevel;
      user["Interests"] = _selectedTags;

      final cUser = FirebaseAuth.instance.currentUser!;
      db.collection("users").doc(cUser.uid).set(user, SetOptions(merge: true));

      final providerModel = Provider.of<ProviderModel>(context, listen: false);
      providerModel.setProfilePicture(user['ProfilePicture']);
      providerModel.setSchoolWanted(user['SchoolWanted']);
      providerModel.setCurrentLevel(user['CurrentLevel']);
      providerModel.setInterests(user['Interests']);
      providerModel.setDescription(user['Description']);

      getUserInfos();
      _verifyBtnController.success();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BottomNavigationBarPage(),
        ),
      );
    };
    _verifyBtnController.stop();
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

  void changeUser(String Name, String ProfilePicture) {
    final providerModel = Provider.of<ProviderModel>(context, listen: false);
    providerModel.setProfilePicture(ProfilePicture);
  }

  void _updateTagsValidity() {
    setState(() {
      _areTagsValid = _selectedTags.isNotEmpty;
    });
  }

  void _showTagsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choisir les centres d'Interêt", style: TextStyle(fontSize: 20)),
          content: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('contents').doc('interests').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Text("Pas de centre d'interêt disponible");
              }

              List<String> allTags = List.from(snapshot.data!.get('tags'));
              List<String> availableTags = allTags.where((tag) => !_selectedTags.contains(tag)).toList();

              return Wrap(
                spacing: 5.0,
                children: availableTags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTags.add(tag);
                          _areTagsValid = _selectedTags.isNotEmpty;
                        });
                        Navigator.pop(context);
                      },
                      child: Chip(label: Text(tag)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTags() {
    return Wrap(
      spacing: 8.0,
      children: _selectedTags.map((tag) {
        return Chip(
          label: Text(tag),
          deleteIcon: Icon(Icons.cancel, size: 17),
          onDeleted: () {
            setState(() {
              _selectedTags.remove(tag);
            });
            _updateTagsValidity();
          },
        );
      }).toList(),
    );
  }
}
