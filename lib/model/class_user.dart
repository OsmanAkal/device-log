class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String rol; // admin / personel

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.rol,
  });

  // Firebase'den gelen veriyi modele çevirme
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data["name"] ?? "",
      surname: data["surname"] ?? "",
      email: data["email"] ?? "",
      rol: data["rol"] ?? "personel",
    );
  }

  // Firebase'e gönderme (kaydetme)
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "surname": surname,
      "email": email,
      "rol": rol,
    };
  }
}