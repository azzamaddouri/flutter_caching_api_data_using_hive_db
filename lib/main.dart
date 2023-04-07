import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

const String API_BOX = "api_data";
const String FAVORITES_BOX = "favorites_data";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(API_BOX);
  await Hive.openBox(FAVORITES_BOX);
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
        routes: {
          'favorites': (_) => FavoritesPage(),
        });
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Flutter Offline Caching Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, 'favorites');
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: APIService().getPosts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final List posts = snapshot.data;
            return ValueListenableBuilder(
                valueListenable: Hive.box(FAVORITES_BOX).listenable(),
                builder: (context, box, _) {
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      Text("List of posts "),
                      // The three dots are called spread operator and it is used to spread the elements of an iterable into a new collection
                      ...posts.map((post) => ListTile(
                            title: Text(post['title']),
                            trailing: IconButton(
                              icon: Icon(box.containsKey(post['id'])
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                              onPressed: () {
                                if (box.containsKey(post['id'])) {
                                  box.delete(post['id']);
                                } else {
                                  box.put(post['id'], post);
                                }
                              },
                            ),
                          )),
                      ElevatedButton(onPressed: () {}, child: Text("Clear"))
                    ],
                  );
                });
          }),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(' Favorites Page'),
        ),
        body: ValueListenableBuilder(
            valueListenable: Hive.box(FAVORITES_BOX).listenable(),
            builder: (context, box, child) {
              List posts = List.from(box.values) ?? [];
              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text("List of posts "),
                  // The three dots are called spread operator and it is used to spread the elements of an iterable into a new collection
                  ...posts.map((post) => ListTile(
                        title: Text(post['title']),
                        trailing: IconButton(
                            onPressed: () {
                              box.delete(post["id"]);
                            },
                            icon: Icon(Icons.clear)),
                      )),
                ],
              );
            }));
  }
}

class APIService {
  Future getPosts() async {
    final posts = Hive.box(API_BOX).get("posts", defaultValue: []);
    if (posts.isNotEmpty) {
      return posts;
    }
    final response =
        await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    final responseJson = jsonDecode(response.body);
    Hive.box(API_BOX).put("posts", responseJson);
    return responseJson;
  }
}
