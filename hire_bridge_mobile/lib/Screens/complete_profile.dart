import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hire_bridge/Model/student.dart';
import 'package:hire_bridge/Provider/student_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    Key? key,
    required int studentID,
    required String fcmToken,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _gpaController;
  late TextEditingController _skillsController;
  late TextEditingController _interestsController;
  late TextEditingController _fypTitleController;
  late TextEditingController _fypDescriptionController;
  late TextEditingController _cvPathController;

  // Dropdown state
  String? _selectedDepartment;
  String? _selectedDegree;

  final Map<String, List<String>> departmentDegrees = {
    'Computer Science': ['BCS', 'BSE', 'BAI'],
    'Civil Engineering': ['CVE'],
    'Electrical Engineering': ['BCE', 'BEE'],
    'Mechanical Engineering': ['BME'],
    'Management Sciences': ['BBA', 'BAF'],
  };
  Future<void> _pickAndUploadCV() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // important for web to get bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;

        // On web, path is null; use bytes instead
        final fileBytes = pickedFile.bytes;
        final fileName = pickedFile.name;

        if (fileBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file bytes')),
          );
          return;
        }

        // Prepare multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:5214/api/Student/uploadCV'),
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
            contentType: MediaType('application', 'octet-stream'),
          ),
        );

        final streamedResponse = await request.send();

        if (streamedResponse.statusCode == 200) {
          final respStr = await streamedResponse.stream.bytesToString();
          final data = jsonDecode(respStr);

          setState(() {
            _cvPathController.text = data['filePath'] ?? '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CV uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to upload CV')));
        }
      } else {
        // User cancelled the picker
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final student = context.read<StudentProvider>().student;

    _selectedDepartment = _getDepartmentFromDegree(student?.degreeProgram);
    _selectedDegree = student?.degreeProgram;

    _gpaController = TextEditingController(
      text: student?.gpa?.toString() ?? '',
    );
    _skillsController = TextEditingController(text: student?.skills ?? '');
    _interestsController = TextEditingController(
      text: student?.interests ?? '',
    );
    _fypTitleController = TextEditingController(text: student?.fypTitle ?? '');
    _fypDescriptionController = TextEditingController(
      text: student?.fypDescription ?? '',
    );
    _cvPathController = TextEditingController(text: student?.cvPath ?? '');
  }

  @override
  void dispose() {
    _gpaController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    _fypTitleController.dispose();
    _fypDescriptionController.dispose();
    _cvPathController.dispose();
    super.dispose();
  }

  String? _getDepartmentFromDegree(String? degree) {
    if (degree == null) return null;
    for (var entry in departmentDegrees.entries) {
      if (entry.value.contains(degree)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final studentProvider = context.read<StudentProvider>();
    final student = studentProvider.student;
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No student data available")),
      );
      return;
    }

    if (_selectedDegree == null || _selectedDegree!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a degree")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiUrl = 'http://localhost:5214/api/Student/updateProfile';

    final body = jsonEncode({
      "studentID": student.studentID,
      "degreeProgram": _selectedDegree,
      "gpa": double.tryParse(_gpaController.text.trim()) ?? 0,
      "skills": _skillsController.text.trim(),
      "interests": _interestsController.text.trim(),
      "fypTitle": _fypTitleController.text.trim(),
      "fypDescription": _fypDescriptionController.text.trim(),
      "cvPath": _cvPathController.text.trim(),
      "fcmToken": student.fcmToken,
    });

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        // Update local provider data
        studentProvider.updateProfile(
          degreeProgram: _selectedDegree,
          gpa: double.tryParse(_gpaController.text.trim()),
          skills: _skillsController.text.trim(),
          interests: _interestsController.text.trim(),
          fypTitle: _fypTitleController.text.trim(),
          fypDescription: _fypDescriptionController.text.trim(),
          cvPath: _cvPathController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonDecode(response.body)['message'] ?? 'Profile updated',
            ),
          ),
        );

        // You can navigate to another screen here if you want
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to update profile'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF004A99);

    // Convert to List<String> forcibly to avoid List<dynamic> errors
    final List<String> degrees =
        _selectedDepartment != null
            ? List<String>.from(departmentDegrees[_selectedDepartment] ?? [])
            : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown<String>(
                label: 'Department',
                value: _selectedDepartment,
                items: departmentDegrees.keys.toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDepartment = val;
                    _selectedDegree = null; // reset degree when dept changes
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Degree Program',
                value: _selectedDegree,
                items: degrees,
                onChanged: (val) {
                  setState(() {
                    _selectedDegree = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _gpaController,
                label: 'GPA',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final gpa = double.tryParse(value);
                  if (gpa == null || gpa < 0 || gpa > 4) {
                    return 'Please enter a valid GPA between 0 and 4';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _skillsController, label: 'Skills'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _interestsController,
                label: 'Interests',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fypTitleController,
                label: 'FYP Title',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fypDescriptionController,
                label: 'FYP Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload CV',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _cvPathController.text.isEmpty
                              ? 'No file selected'
                              : _cvPathController.text,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _pickAndUploadCV,
                        child: const Text('Choose File'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
