class Student {
  const Student({
    required this.studentId,
    required this.firstname,
    required this.lastname,
  });

  final int studentId;
  final String firstname;
  final String lastname;

  @override
  String toString() {
    return "$lastname $firstname";
  }
}