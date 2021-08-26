import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class ApiData {
  fetchNotification() async {
    var url = Uri.https('attendanceapp.genxmtech.com', 'push/api.php');
    var response = await http.get(url);
    List<dynamic> notifications = [];
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      // for (int i = 0; i < jsonResponse['data'].length; i++) {
      //   notifications.add(jsonResponse['data'][i]);
      // }
      // return notifications;
    } else {
      return false;
    }
  }
}
