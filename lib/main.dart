import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

const String API_BOX = "api_data";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(API_BOX);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Flutter Offline Caching Page'),
      ),
      body: FutureBuilder(
          future: APIService().getPosts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final List posts = snapshot.data;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text("List of posts "),
                // The three dots are called spread operator and it is used to spread the elements of an iterable into a new collection
                ...posts.map((post) => ListTile(title: Text(post['title']))),
                ElevatedButton(onPressed: () {}, child: Text("Clear"))
              ],
            );
          }),
    );
  }
}

class APIService {
  Future getPosts() async {
    final response =
        await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    final responseJson = jsonDecode(response.body);
    return responseJson;
  }
}
