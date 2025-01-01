class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final bool ehNutricionista;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.ehNutricionista,
  });
}