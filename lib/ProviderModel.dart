import 'package:flutter/foundation.dart';

class ProviderModel extends ChangeNotifier {
  String role = "Debug";
  String firstName = "FirstNameDebug";
  String lastName = "LastNameDebug";
  String email = "EmailDebug";
  String profilePicture = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  String uid = "UIDDebug";
  String description = "DescriptionDebug";
  String currentLevel = "LevelDebug";
  String schoolWanted = "SchoolWantedDebug";
  List<String> interests = ["InterestsDebug"];

  void setProfilePicture(String newProfilePicture) {
    profilePicture = newProfilePicture;
    notifyListeners();
  }
  void setEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }
  void setRole(String newRole) {
    role = newRole;
    notifyListeners();
  }
  void setFirstName(String newFirstName) {
    firstName = newFirstName;
    notifyListeners();
  }
  void setLastName(String newLastName) {
    lastName = newLastName;
    notifyListeners();
  }
  void setUID(String newUID) {
    uid = newUID;
    notifyListeners();
  }
  void setSchoolWanted(String newSchoolWanted) {
    schoolWanted = newSchoolWanted;
    notifyListeners();
  }
  void setCurrentLevel(String newCurrentLevel) {
    currentLevel = newCurrentLevel;
    notifyListeners();
  }
  void setInterests(List<String> newInterests) {
    interests = newInterests;
    notifyListeners();
  }
  void setDescription(String newDescription) {
    description = newDescription;
    notifyListeners();
  }
}