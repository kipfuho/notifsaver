import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:prj3/models/log_model.dart';
import 'package:prj3/secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthenticatedClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client;

  AuthenticatedClient(this._accessToken, this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}

class GoogleService {
  // Singleton
  static final GoogleService _instance = GoogleService._internal();
  factory GoogleService() {
    return _instance; // Return the single instance
  }
  GoogleService._internal(); // Private constructor

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope, // Grants file access to Google Drive
    ],
  );

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null; // User canceled the sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Save credentials securely
    await SecureStorage.writeSecureStorage(
        'userAccessToken', googleAuth.accessToken);
    return userCredential.user;
  }

  // Method to sign out from Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String> getFolderId(drive.DriveApi driveApi, String folderName) async {
    try {
      var query =
          "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
      var fileList = await driveApi.files.list(q: query);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id ?? 'root';
      }
      return createFolder(driveApi, folderName);
    } catch (e) {
      LogModel.logError("Error searching for folder: $e");
      return 'root';
    }
  }

  Future<String> createFolder(
      drive.DriveApi driveApi, String folderName) async {
    try {
      var folder = drive.File()
        ..name = folderName
        ..mimeType = "application/vnd.google-apps.folder";

      var createdFolder = await driveApi.files.create(folder);
      return createdFolder.id ?? 'root';
    } catch (e) {
      LogModel.logError("Error creating folder: $e");
      return 'root';
    }
  }

  // Get Google Drive API client using Firebase access token
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      // Get OAuth2 access token from secure storage
      final accessToken =
          await SecureStorage.readSecureStorage('userAccessToken');
      final authenticateClient =
          AuthenticatedClient(accessToken!, http.Client());

      return drive.DriveApi(authenticateClient);
    } catch (e) {
      LogModel.logError("Error getting Drive API client: $e");
      return null;
    }
  }
}
