import 'package:flutter/material.dart';
import 'helpers/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // remove debug mark
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColorScheme),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 新增一個控制器來獲取新的數據
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _illuminationController = TextEditingController();

  // 新增一個方法來上傳新的數據
  void _uploadData() {
    double angle = double.tryParse(_angleController.text) ?? 0.0;
    int illumination = int.tryParse(_illuminationController.text) ?? 0;

    // 上傳新的數據
    FirebaseFirestore.instance.collection('TEST_123').add({
      'angle': angle,
      'illumination': illumination,
      'time': Timestamp.now(),
      // 其他字段...
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('TEST_123')
                  .orderBy('time', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                // 獲取文檔數據
                final documents = snapshot.data!.docs;
                if (documents.isNotEmpty) {
                  var latestDocument =
                  documents[0].data() as Map<String, dynamic>;

                  // 提取特定字段的數據
                  final angle = latestDocument['angle'];
                  final illumination = latestDocument['illumination'];
                  // 其他字段...

                  // 做一些處理，例如將數據顯示在UI上
                  String firestoreData = 'Angle: $angle deg \nIllumination: $illumination lux';

                  return Text(
                    firestoreData,
                    style: Theme.of(context).textTheme.headlineLarge,
                  );
                } else {
                  return const Text('No data available.');
                }
              },
            ),
            SizedBox(height: 20),
            // 新增一個按鈕和文本輸入框
            ElevatedButton(
              onPressed: _uploadData,
              child: Text('Upload Data'),
            ),
            SizedBox(height: 20),
            Text('Enter new data:'),
            TextField(
              controller: _angleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Angle'),
            ),
            TextField(
              controller: _illuminationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Illumination'),
            ),
          ],
        ),
      ),
    );
  }
}
