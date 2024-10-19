
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriveScreen extends StatefulWidget {
  final User user;

  const DriveScreen({super.key, required this.user});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  Future<void> _uploadFileToGoogleDrive() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final accessToken = googleAuth.accessToken;

        // Upload a file to Google Drive (this is just an example)
        var url = Uri.parse("https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart");
        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $accessToken';

        // Add file and metadata (replace this with your actual file)
        request.fields['name'] = 'test.txt';  // file name
        request.files.add(await http.MultipartFile.fromPath('file', 'path/to/file'));

        var response = await request.send();

        if (response.statusCode == 200) {
          print('File uploaded to Google Drive');
        } else {
          print('Failed to upload file');
        }
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Drive'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadFileToGoogleDrive,
          child: const Text('Upload File to Google Drive'),
        ),
      ),
    );
  }
}
