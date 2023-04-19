import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url = 'https://owlbot.info/api/v4/dictionary/';
  String _token = 'd166297c41adc84ea6c604d22b221238c25f0ba4';

  TextEditingController _inputWord = TextEditingController();

  StreamController _streamController = StreamController();
  Stream? _stream;

  Timer? _debounce;

  @override
  void initState() {
    //_streamController = StreamController();
    _stream = _streamController.stream;
    super.initState();
  }

  _search() async {
    if (_inputWord.text == null || _inputWord.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    if (_inputWord.text.trim().toLowerCase() == 'pussy') {
      _streamController.add("pussy");
      return;
    }
    /*try {*/
    Response response = await get(Uri.parse(_url + _inputWord.text.trim()),
        headers: {"Authorization": "Token " + _token});
    if (response.statusCode == 200) {
      _streamController.add(json.decode(response.body));
    } else {
      _streamController.add("wrong");
    }
    /*} on FormatException catch (e) {
      if (e.message.contains('404')) {
        _streamController.add("wrong");
      } else {
        _streamController.add("wrong");
      }
    } catch (e) {
      _streamController.add("wrong");
    }*/
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    _inputWord.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 12,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    onFieldSubmitted: (value) {
                      _search();
                    },
                    onChanged: (String word) {
                      // if (_debounce?.isActive ?? false) _debounce!.cancel();
                      // _debounce = Timer(const Duration(milliseconds: 2000), () {
                      //   _search();
                      // });
                    },
                    controller: _inputWord,
                    decoration: InputDecoration(
                      hintText: 'Search for a word',
                      contentPadding: EdgeInsets.only(left: 24),
                      border: InputBorder.none,
                    ),
                    //onSubmitted: (value) => _search(),
                  ),
                ),
              ),
              IconButton(
                onPressed: _search,
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(48),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text('Enter a word to search'),
              );
            }
            if (snapshot.data == 'waiting') {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == 'pussy') {
              return Center(
                child: Image.network(
                  'https://cdnxw1.youx.xxx/gthumb/2/583/2583029_3ffc3b6_320x_.jpg',
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
              );
            }

            if (snapshot.data == 'wrong') {
              return Center(
                child: Text('Invalid search - Please enter a valid word'),
              );
            }

            return ListView.builder(
              itemBuilder: ((context, index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]
                                    ["image_url"] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data["definitions"][index]["image_url"]),
                              ),
                        title: Text(_inputWord.text.trim() +
                            "(" +
                            snapshot.data["definitions"][index]["type"] +
                            ")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );
              }),
              itemCount: snapshot.data["definitions"].length,
            );
          },
          stream: _stream,
        ),
      ),
    );
  }
}
/**/