class Tutor {
  const Tutor({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.subjects,
  });

  final int id;
  final String firstname;
  final String lastname;
  final List<String>? subjects;
}