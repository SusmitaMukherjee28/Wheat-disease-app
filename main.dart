
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheat Guard',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('bn'),
      ],
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  String _result = '';
  final picker = ImagePicker();

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
      });
    }
  }

  Future captureImageWithCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
      });
    }
  }

  Future sendImage() async {
    if (_image == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.29.31:5000/predict-api'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);

        String predictionKey = data['prediction'].toString().toLowerCase().replaceAll(' ', '');
        String translatedPrediction = '';
        final local = AppLocalizations.of(context)!;

        switch (predictionKey) {
          case 'loosesmut':
            translatedPrediction = local.looseSmut;
            break;
          case 'brownrust':
            translatedPrediction = local.brownRust;
            break;
          case 'yellowrust':
            translatedPrediction = local.yellowRust;
            break;
          case 'septoria':
            translatedPrediction = local.septoria;
            break;
          case 'healthy':
            translatedPrediction = local.healthy;
            break;
          default:
            translatedPrediction = data['prediction'];
        }

        setState(() {
          _result = '${local.prediction}: $translatedPrediction (${data['confidence']}%)';
        });
      } else {
        setState(() {
          _result = AppLocalizations.of(context)!.predictionFailed;
        });
      }
    } catch (e) {
      setState(() {
        _result = "${AppLocalizations.of(context)!.error}: $e";
      });
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              onTap: () {
                MyApp.setLocale(context, const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("हिंदी"),
              onTap: () {
                MyApp.setLocale(context, const Locale('hi'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("বাংলা"),
              onTap: () {
                MyApp.setLocale(context, const Locale('bn'));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/background.jpg",
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.language, color: Colors.white, size: 30),
                      onPressed: _showLanguagePicker,
                    ),
                  ),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/logo.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    local.appTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _image != null
                      ? Image.file(_image!, height: 200)
                      : Text(
                          local.noImageSelected,
                          style: const TextStyle(color: Colors.white),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickImageFromGallery,
                    child: Text(local.chooseFromGallery),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: captureImageWithCamera,
                    child: Text(local.captureWithCamera),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: sendImage,
                    child: Text(local.predict),
                  ),
                  const SizedBox(height: 20),
                  if (_result.isNotEmpty)
                    Text(
                      _result,
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 40),
                  Text(
                    local.aboutThisApp,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    local.aboutDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
