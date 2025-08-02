import 'package:flutter/material.dart';
import 'package:hire_bridge/Model/student.dart';

class StudentProvider with ChangeNotifier {
  Student? _student;

  Student? get student => _student;

  void setStudent(Student student) {
    _student = student;
    notifyListeners();
  }

  void clear() {
    _student = null;
    notifyListeners();
  }

  void updateProfile({
    String? degreeProgram,
    double? gpa,
    String? skills,
    String? interests,
    String? fypTitle,
    String? fypDescription,
    String? cvPath,
    String? fcmToken,
  }) {
    if (_student == null) return;

    _student = Student(
      studentID: _student!.studentID,
      userID: _student!.userID,
      registrationNumber: _student!.registrationNumber,
      name: _student!.name,
      email: _student!.email,
      degreeProgram: degreeProgram ?? _student!.degreeProgram,
      gpa: gpa ?? _student!.gpa,
      skills: skills ?? _student!.skills,
      interests: interests ?? _student!.interests,
      fypTitle: fypTitle ?? _student!.fypTitle,
      fypDescription: fypDescription ?? _student!.fypDescription,
      cvPath: cvPath ?? _student!.cvPath,
      fcmToken: fcmToken ?? _student!.fcmToken,
    );
    notifyListeners();
  }
}
