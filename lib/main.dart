import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? timer; // CountDown
  Duration duration = Duration();
  var seed = 12345;
  int count5close = 0;
  bool isopened = false;
  bool isshowingQR = false;
  String doorindex = "d=door1&s=";
  late String qrData = doorindex + seed.toString();
  bool randis0index = false;
  num count5sec = 0;
  num QRcount8sec = 0;
  var seed2random = List<int>.filled(2, 0); // Creates fixed-length list.
  Uint8List secret = Uint8List(0);
  Uint8List share1 = Uint8List(0);
  int userlength = 0;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  void initState() {
    super.initState();
    startTimer();
    setState(() {
      duration = Duration(minutes: 1);
    });
    seed2random[0] = 12345;
    rootBundle.load('assets/images/secret.png').then((data) {
      final buffer = img
          .decodeImage(data.buffer.asUint8List())!
          .getBytes(format: img.Format.luminance)
          .map((e) => e == 0 ? 0 : 1)
          .toList();
      setState(() {
        secret = Uint8List.fromList(buffer);
      });
    });
    rootBundle.load('assets/images/share1.png').then((data) {
      final buffer = img
          .decodeImage(data.buffer.asUint8List())!
          .getBytes(format: img.Format.luminance)
          .map((e) => e == 0 ? 0 : 1)
          .toList();
      setState(() {
        share1 = Uint8List.fromList(buffer); 
      });
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => minusTime());
  }

  void setSeedandResetTime() {
    DateTime now = DateTime.now();
    seed = now.millisecondsSinceEpoch % 1000000007;
    randis0index ? seed2random[0] = seed : seed2random[1] = seed;
    qrData = doorindex + seed.toString();
    duration = Duration(minutes: 1);
    randis0index = !randis0index;
  }

  void minusTime() {
    setState(() {
      final seconds = duration.inSeconds - 1;
      if (seconds < 0) {
        setState(() {
          setSeedandResetTime();
        });
      } else {
        duration = Duration(seconds: seconds);
      }
      if (isopened) {
        ++count5close;
        if (count5close == 5) {
          isopened = false;
          count5close = 0;
        }
      }
      if (result != null) {
        ++count5sec;
        if (count5sec == 5) {
          result = null;
          count5sec = 0;
        }
      }
      if (isshowingQR) {
        ++QRcount8sec;
        if (QRcount8sec == 8) {
          isshowingQR = !isshowingQR;
          QRcount8sec = 0;
        }
      }else{
        QRcount8sec = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Door1"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            height: 60,
            width: 350,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: isopened ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              isopened ? 'Door Opened' : 'Not Opened',
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: testing(),
          ),
          SizedBox(
            height: 40,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              child: TextButton(
                onPressed: () {
                  if (isshowingQR) {
                    setState(() {
                      setSeedandResetTime();
                    });
                  } else {
                    isshowingQR = !isshowingQR;
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isshowingQR ? "updateQRCode" : "Scan QR",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(5)),
            ),
            SizedBox(width: 20),
            Container(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    count5sec = 0;
                    isshowingQR = !isshowingQR;
                    result = null;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isshowingQR ? "Return" : "Scan QR",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(5)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            child: Text(
          minutes,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 30,
          ),
        )),
        Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        Container(
            child: Text(
          seconds,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 30,
          ),
        )),
      ],
    );
  }

  Widget testing() {
    return isshowingQR
        ? Column(children: [
            Container(
              child: buildTime(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Please Scan the Qr Code Below",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            QrImage(
              data: qrData,
              version: 10,
              size: 300,
              backgroundColor: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
          ])
        : Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                height: 300,
                width: 300,
                child: QRView(
                  key: qrKey,
                  cameraFacing: CameraFacing.front,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderWidth: 20,
                    borderLength: 10,
                    cutOutSize: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: (result != null
                    ? Text(
                        "User QR code Scanned.",
                        style: TextStyle(fontSize: 20),
                      )
                    : Text(
                        "Please show your User QR code.",
                        style: TextStyle(fontSize: 20),
                      )),
              ),
            ],
          );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        transferData(result!.code);
      });
    });
  }

  void transferData(String? data) {
    //debugPrint(data);
    if (data != null) {
      var buffer = base64Decode(data); // length = 200
      userlength = buffer.length;
      for (var i = 0; i < 2; ++i) {
        Random rng = Random(seed2random[i]);
        final Userimage = buffer
            .map((e) => e ^ rng.nextInt(256))
            .map(
              (e) {
                final tmp = List.filled(8, 0);
                for (int idx = 0; idx < 8; idx++) {
                  tmp[idx] = (e >> idx) & 1;
                }
                return tmp;
              },
            )
            .expand((e) => e)
            .toList();
        Uint8List overlapped = Uint8List(share1.length);
        for (int idx = 0; idx < share1.length; idx++) {
          overlapped[idx] = Userimage[idx] & share1[idx];
        }
        if (validUser(overlapped)) {
          isopened = true;
          if ((!randis0index && i == 0) || (randis0index && i == 1)) {
            randis0index = !randis0index;
            setSeedandResetTime();
          }
          break;
        }
      }
    }
  }

  bool validUser(Uint8List overlapped) {
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        int count = 0; // count white
        count += overlapped[i * 2 * 40 + j * 2];
        count += overlapped[i * 2 * 40 + j * 2 + 1];
        count += overlapped[(i * 2 + 1) * 40 + j * 2];
        count += overlapped[(i * 2 + 1) * 40 + j * 2 + 1];
        if (secret[i * 20 + j] == 0) {
          // if secret is black
          if (count != 0) return false;
        } else {
          // if secret is white
          if (count != 1) return false;
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
