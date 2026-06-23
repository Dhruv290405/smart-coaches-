import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var url1 = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api/acp/filters';
  var url2 = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api/acp/filters?trainNo=13288';
  var url3 = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api/acp/filters?trainNo=13288&coachType=GS';
  var url4 = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api/acp/filtered-logs?trainNo=13288&techCoachNo=154269/C';

  try {
    print('Testing $url1');
    var res1 = await http.get(Uri.parse(url1));
    print(res1.body);
    
    print('Testing $url2');
    var res2 = await http.get(Uri.parse(url2));
    print(res2.body);

    print('Testing $url3');
    var res3 = await http.get(Uri.parse(url3));
    print(res3.body);

    print('Testing $url4');
    var res4 = await http.get(Uri.parse(url4));
    print(res4.body);
  } catch(e) {
    print(e);
  }
}
