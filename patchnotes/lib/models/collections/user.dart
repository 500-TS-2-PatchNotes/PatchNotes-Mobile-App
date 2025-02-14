class User {
  final String uid; // (foreign). To reference the user's id. From Firebase Authentication.
  final String email;
  final String fName;
  final String lName;

  User({
    required this.uid,
    required this.email,
    required this.fName,
    required this.lName,
  });
}
