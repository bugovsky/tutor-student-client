class StudentRequest {
  const StudentRequest({
    required this.studentId,
    required this.firstname,
    required this.lastname,
  });

  final int studentId;
  final String firstname;
  final String lastname;
}