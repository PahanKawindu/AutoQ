import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationHandler {

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "testapp1-bc440",
      "private_key_id": "657d126be981fb29c76ec5941a7973fa8bce742e",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDyctgHNpd5DgMN\nApTCUHf81pqhK2va9+2OxnZ5E57i5FAalR1w4mDNSb+h4DHn6pTCkrJdxqSvvpuq\nICTE/2HsaIi3hofIsWXF+4mqMsjVrF6m4bXjCV/A2kErLirKXNisTrO2b6nSa803\nYY/BRTMJQc9rA33KLJb3PxTAXxBa5ChbRF+5NQ3bVrSQxAiKBarMZ1hPQzikrY04\nDA3pMPyx75EIchPMPM6JhMT2W0In/0+VRMzWCBA5zeWWQwsn9H4RK8dcfDMtqiC9\n98C3qhqF3zjD/t6mJqbTKANK6YDDzuO/qT4vv2IoZ+dSc7/J/YvJsKjjpK+YVjvU\nlX4oVz2NAgMBAAECggEAUtg/TSewVqMdE8MABe3tMi46pDvsHOR+/jx+mxzDPBB7\n9rlhWANixIMgwjWTmAWmU15BKJ4KBCuDkXxuVApX8ao+nUeQ+ljzx9UN02SLD8hY\nh3m05yF64LEzd4fNA1z6hNZXvk0loEtJ0lS6BHaa29zq/UwyHXVjGJUriBhzxDpr\n6lJjP1yNrGfEQirF65rCrMm+qaT5PpOYvk/CGbVQtriozGJP/EiSeRx+OLHQccIS\nW4BGw27VkTbcQttg6XxtahT6GpIDZtCfoG16o94rsWdGolfPsKvzlgd4E29HBMqp\nVuSFGw9s7TDcJS+O9eyYPm7oE2665ZYJfCDCOginWQKBgQD+zleDNeuS3VuD8Mpe\nqk2scV4MsxkiC57vnHQ1GBz6hOfiQELB+8u5/Lqhzdurl0W6dKGtZqcXHASFdSw0\nAOmQWppakiWPUMJb01PoPS37+R92GjoT9alSUcmfkt9i6IeqaGSoD+0IHb/7/m5+\nJBNcowmtcoPsOdONAOdESYeI/wKBgQDzla2sF1/rmwkPc3i2t/9YvUCKDnwiZoUI\nRBb2RUx/sd9tD56urZGhAKwl+stYD+JwGAiKjYRmVWh20Ba6kERZzgtOkgCDtSsw\nHEN2+V3gUiOyAAyyRBN4YMbIMVBNOnwJYPyFfBGjLJZkBdq6pXxHTkLbrlLgLFxU\nN8XuY8BNcwKBgQCdXZxombV6x6EMdHrXSkCcXouiNj4wa5LmEu8mF1VWVxzK+7r/\nCN5CaFZvNa8UY2GaDQwJBpvtRs14CuyY1XNqRrqLczUlNNBEW9i3Vol+09XdX8c8\nqny/LWnjVpcGA+w9jymTLfrLB2yZWgKtfuRCUyLX7yCQlQoVTFiIMQ02ywKBgQCc\niscQX/1PJ1XNTkJ3+wvpdcbycpioawZ353pyTtr4/dE+/9jVHcsHk60Ow3zHXX4C\n2A81K/m44o6+PME+qNSkelyd5ArcmiPlSWS6I0yHi4JRNOLz9fglVtypb7fRyhJI\n3MGs761OFquYIIMPjKawFMW29PNiCmBT53wW1piRrQKBgQD+AsygXhn6XrrWDcTj\naVQBLH5A/lJiuxxFuBLzlfvZET+mTCwgppaifRUDfp+A/vkiFHYTDx8Q/SaOx5kN\nADHce3wUKGyqpZKfeZN7+dQxT8Nnvq6OpAm/jxdMbzsX8dMQkpcKm0A14wl5WLLi\ny4LsFL5LC8dd8b69IXlWIzf1Wg==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-v5rn4@testapp1-bc440.iam.gserviceaccount.com",
      "client_id": "118363518441768080005",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-v5rn4%40testapp1-bc440.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
    ;
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
      String deviceToken, String title, String body) async {
    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/testapp1-bc440/messages:send';
    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
        "data": {
          "route": "serviceScreen",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }
}
