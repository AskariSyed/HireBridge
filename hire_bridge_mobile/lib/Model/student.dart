import 'package:flutter/material.dart';

class Student {
  final int studentID;
  final int userID;
  final String registrationNumber;
  final String name;
  final String email;
  final String? degreeProgram;
  final double? gpa;
  final String? skills;
  final String? interests;
  final String? fypTitle;
  final String? fypDescription;
  final String? cvPath;
  final String? fcmToken;

  Student({
    required this.studentID,
    required this.userID,
    required this.registrationNumber,
    required this.name,
    required this.email,
    this.degreeProgram,
    this.gpa,
    this.skills,
    this.interests,
    this.fypTitle,
    this.fypDescription,
    this.cvPath,
    this.fcmToken,
  });
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentID'] ?? json['StudentID'],
      userID: json['userID'] ?? json['UserID'],
      registrationNumber:
          json['registrationNumber'] ?? json['RegistrationNumber'],
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      degreeProgram: json['degreeProgram'] ?? json['DegreeProgram'],
      gpa:
          json['gpa'] != null
              ? (json['gpa'] is int
                  ? (json['gpa'] as int).toDouble()
                  : json['gpa'] as double)
              : null,
      skills: json['skills'] ?? json['Skills'],
      interests: json['interests'] ?? json['Interests'],
      fypTitle: json['fypTitle'] ?? json['FYPTitle'],
      fypDescription: json['fypDescription'] ?? json['FYPDescription'],
      cvPath: json['cvPath'] ?? json['CVPath'],
      fcmToken: json['fcmToken'] ?? json['FCMToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'userID': userID,
      'registrationNumber': registrationNumber,
      'name': name,
      'email': email,
      'degreeProgram': degreeProgram,
      'gpa': gpa,
      'skills': skills,
      'interests': interests,
      'fypTitle': fypTitle,
      'fypDescription': fypDescription,
      'cvPath': cvPath,
      'fcmToken': fcmToken,
    };
  }
}
