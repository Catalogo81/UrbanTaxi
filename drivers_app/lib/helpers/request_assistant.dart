import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelpers {
  static Future<dynamic> processRequest(String url) async {
    http.Response httpResponse =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        return "Unexpected Error Occurred. Please Try Again Later";
      }
    } on TimeoutException catch (_) {
      return "Took too long. Request Timed Out.";
    } catch (exp) {
      return "Unexpected Error Occurred. Please Try Again Later";
    }
  }
}
