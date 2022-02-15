import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dummy_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Api integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showingList = false;
  late Future<DummyData> getSingle;
  late Future<DummyData> postSingle;
  late Future<List<DummyData>> getAll;
  late Future<List<DummyData>> postAll;

  late Future<DummyData> genericData;

  @override
  void initState() {
    super.initState();
    genericData = getSingle = fetchSingleData();
    getAll = fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      getSingleData();
                    },
                    child: Text('GetSingleData'),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      getAllData();
                    },
                    child: Text('GetAllData'),
                  ),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: postSingleData(),
                    child: Text('PostSingleData'),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: postAllData(),
                    child: Text('PostAllData'),
                  ),
                ))
              ],
            ),
            Flexible(
              child:
                  // wrap with a scrollable widget
                  showingList ? showListData() : showSingleData(),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<DummyData> fetchSingleData() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return DummyData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load get Single Data');
    }
  }

  Future<List<DummyData>> fetchAllData() async {
    final response =
        await http.get('https://jsonplaceholder.typicode.com/posts');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DummyData.fromJson(data)).toList();
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  postAllData() {
    /*setState(() {
      genericData = getSingle;
    });*/
  }

  postSingleData() {
    /*   setState(() {
      showingList = false;
    });*/
  }

  getSingleData() {
    setState(() {
      showingList = false;
    });
  }

  getAllData() {
    setState(() {
      showingList = true;
      showingList = true;
    });
  }

  Widget showSingleData() {
    return FutureBuilder<DummyData>(
      future: getSingle,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: [
            Text(snapshot.data!.title),
            Text(snapshot.data!.userId.toString())
          ]);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Widget showListData() {
    return FutureBuilder<List<DummyData>>(
      future: getAll,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DummyData>? data = snapshot.data;
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data?.length,
              /*physics: const NeverScrollableScrollPhysics(),*/
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  Text(snapshot.data![index].title),
                  Text(snapshot.data![index].userId.toString())
                ]);
              });
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}
