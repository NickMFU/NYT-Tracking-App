import 'package:googleapis_auth/auth_io.dart';

class ServiceKey {
  Future<String> getKeyService() async {
    // Define the correct scope for Firebase Cloud Messaging
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Define the service account credentials as a JSON object
    final serviceAccountCredentials = {
  "type": "service_account",
  "project_id": "namyongapp",
  "private_key_id": "e1d7c620f03d612b56468285d6d46c0fb8f2ac38",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCdCBAA0Qa+Pwwo\nD7SvkWB0wWaaV/ezdCaJTDFOjvRA1HKEtZyFVRXjfKujraEQ4oE/CaF/vJo+36oP\ngA4DwZ9ss7epioKvXl4J1oEjn2S+tcvBP+/zTgvPim1SJHCnJf6L0rFyjjE/TxsT\nEKHW6b7BHLuxpizoWqVzqXs4kb09erlgjj6HUBfkCdy/s5FdVWpK/8Yzos6G9RWP\ns+F0XgNsA643jd1XRPwniIsf0NPfaJjzTNV2B3O/q88kpgg5AmNzk+1EG22fyKea\nr6q6v1y8+hdaNvyGrlZ6ycDREz1t6QA6k8GPTVFN6QyQnSbIIvrqOSmDCBAX3zSo\n/lJQFWdbAgMBAAECggEAEKhSSkPiGzxE5dsEp7scKEZ7w9OhCwA/NkFG2baAYoAm\nxb0eJWapM8B91JcOhuQAIde7sfknw5OmTo6e7fcUGkvWJ73xrvirsQ94E3dNEI3o\nV0+Y/I5C4nkkr5n9+T0mi16GREihIL4beSJCiLGy8nlBz8545Qz4kBRiZdXP5T18\n7fewVDPkmOR9Q4Nb7eFdCOxIHXntCQQWfpfaSjSLmFXIhY6RtPnEEseJZproaDTI\nywYQly5ofm5w0pBSe+cfvF3o1rIj6Tn9k67LAoGXbXQrc3sBFi28kLAUrYlc9Dtf\ne1icxjyM/vGT6X3H+M9lJ9TFUt/K0ct38O39yknWQQKBgQDOtQOn7JYUGbvbqo/n\nCwgr1q1ehBjgiCfwV+BKh3kOYwcJZ6Qjbja2dHcKnfra294EGb5S8el5LqBqZDla\nRdBIL0iWWXXfU1fLhqssHqaxJ7Wu8dH0ABpR7ExNVrWJuxT+FCwt/+Fo9Z6cFTsh\nTIahYTlXRR+7Y0TVQ9btGuoUNwKBgQDCengXff7rdSC0fRtv8l1W0j+DUAQXuA7b\neLKQEvCG+Qc3sLhDDzmJ4JjcMYxceJj6yRoDWp3X69Fi8naCfUzHxNKo8CJd3JLI\nIbPTHBMAdeh2RDd/f0G5ydORnTMwZjjqoT7rGKcAX2nbAtUnHj+g2tMl6zvJAruY\n+R1tJr97/QKBgQCaRJAQ8EnlgHsqavXw2dPkW9iR1IZ4dEVSY1MabFbVfOSQiU//\nvU6KBwuc2eCRHExqxQe9AZxce4bvQBNpovbaGKfUxblpzdqVI9F2IP4I8vjuMr2d\nm8II6BDeG1trCjuVkFqUjgadfco89L9nj6Repp/T2Nvgzypc+79Yv6B5KwKBgEiw\nG5i0OAZrZcjwBcRGswpTVPfQfWccHTl8mEjvO0VHaKIxA/3Uf+3/q0KJpmudi5gY\neAeO4/YjJsSz2QWWrY7xCsen0UCBw77Xke2yzYtbhoJFpvSZbMhzHgeL2OkbG+Te\nVbTrJuglwVvhaCfRz3hgsZC3pkXQJqvbWFtGo0VFAoGBAK0e51dT3pMyHiKFFbBB\n26wvGytobiTo5APK7xA8f6B7DW8etjJE+BfDRKipY+dhSHFwxZbjuleRtLT2QnRp\nicAt/YvnH8re6Uwp3rXTOlCwiFyXpWaA9KG9JuwGK2Q2UesjsUiSJPLxju0oixRZ\nnFrsEPIJi3QA9DP5Oo1kbgNT\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-mx3d3@namyongapp.iam.gserviceaccount.com",
  "client_id": "113502189183337165580",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-mx3d3%40namyongapp.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
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