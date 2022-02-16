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
  int showList = 0; // 0 get single data, 1 get all data,
  // 2 show single posted data, 3 show all posted data

  late Future<DummyData> getSingle;
  late Future<DummyData> postSingle;
  late Future<List<DummyData>> getAll;
  late Future<List<DummyData>> postAll;

  late Future<DummyData> genericData;

  final _formKey = GlobalKey<FormState>();
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
  }

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
                    onPressed: () {
                      postSingleData();
                    },
                    child: Text('PostSingleData'),
                  ),
                )),
                /*Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed:(){ postAllData();},
                    child: Text('PostAllData'),
                  ),
                ))*/
              ],
            ),
            Flexible(
              child: getWidget(),
              // wrap with a scrollable widget
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<DummyData> sendSingleData(DummyData data) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': data.userId,
        'title': data.title,
        'body': data.body,
      }),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      return DummyData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
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
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DummyData.fromJson(data)).toList();
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  postAllData() {
   // showPopup(false);
    /*setState(() {
      genericData = getSingle;
    });*/
  }

  postSingleData() {
    showPopup();
    /*   setState(() {
      showingList = false;
    });*/
  }

  getSingleData() {
    setState(() {
      showList = 0;
    });
  }

  getAllData() {
    setState(() {
      showList = 1;
    });
  }

  Widget showPostAllData() {
    return FutureBuilder<List<DummyData>>(
      future: postAll,
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

  Widget showPostSingleData() {
    return FutureBuilder<DummyData>(
      future: postSingle,
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

  showPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller1,
                          decoration:
                              const InputDecoration(hintText: 'Enter Title'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller2,
                          decoration:
                              const InputDecoration(hintText: 'Enter Body'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              DummyData data = DummyData(
                                  userId: 12,
                                  id: 0,
                                  title: controller1.text,
                                  body: controller2.text);

                              // do something with the form data
                              showList = 2;
                              setState(() {
                                postSingle = sendSingleData(data);
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: const Text('Create Data'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget getWidget() {
    if (showList == 0) {
      return showSingleData();
    } else if (showList == 1) {
      return showListData();
    } else if (showList == 2) {
      return showPostSingleData();
    } else if (showList == 3) {
      return showPostAllData();
    } else {
      return showSingleData();
    }
  }
}
