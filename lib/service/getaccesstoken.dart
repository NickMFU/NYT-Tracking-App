import 'package:googleapis_auth/auth_io.dart';

class ServiceKey {
  Future<String> getKeyService() async {
    // Define the correct scope for Firebase Cloud Messaging
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Define the service account credentials as a JSON object
    final serviceAccountCredentials = {
// YOUR_KEY_FIREBASEADMIN_SDK
};

    try {
      // Obtain the client via service account credentials
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountCredentials),
        scopes,
      );

      // Extract the access token from the client
      final accessToken = client.credentials.accessToken.data;

      // Print and return the access token
      print('Access Token: $accessToken');
      client.close(); // Make sure to close the client
      return accessToken;
    } catch (error) {
      // Handle any errors that occur during the authentication process
      print('Error fetching access token: $error');
      return 'Error fetching access token';
    }
  }
}
