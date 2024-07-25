import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../components/header.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class CompleteProcess extends StatefulWidget {
  CompleteProcess({super.key, required this.accessToken, required this.logOutFunction, required this.refreshTokenFunction});
  final String? accessToken;
  final logOutFunction;
  final refreshTokenFunction;

  @override
  State<CompleteProcess> createState() => _CompleteProcessState();
}

class _CompleteProcessState extends State<CompleteProcess> {

  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _clearCanvas() {
    signatureGlobalKey.currentState!.clear();
  }

  void _saveImage() async {
    final data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

    // Directory? directory;
    // if (Platform.isAndroid) {
    //   directory = await getExternalStorageDirectory();
    // } else if (Platform.isIOS) {
    //   directory = await getApplicationDocumentsDirectory();
    // }

    // Getting a directory path for saving
    final String? path = (await getExternalStorageDirectory())?.path;

    // Create a new file in the application documents directory
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final File newImage = File('$path/signature_image_$timestamp.png');

    // Write the image data to the new file
    await newImage.writeAsBytes(bytes!.buffer.asUint8List());

    // Navigate to the new page to display the saved image
    // Navigator.push(
      // context,
      // MaterialPageRoute(
      //   builder: (context) => DisplaySignatureImage(imagePath: newImage.path),
      // ),
    // );
  }

  TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;


  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
          _controller.text = "${date.toLocal()} ${time.format(context)}";
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Daily Work Tasks', logOutFunction: widget.logOutFunction),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Start Time'),
              Expanded(
                child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '2024-05-06',
                    enabled: false
                ),
              ),
              )
            ],
          ),
          Row(
            children: [
              Text('End Time: '),
              Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter date and time',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDateTime(context),
                      ),
                    ),
                  ),
              )
            ],
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: SfSignaturePad(
                      key: signatureGlobalKey,
                      backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                      minimumStrokeWidth: 1.5,
                      maximumStrokeWidth: 5.0
                  )
              )
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
            ElevatedButton(
              child: Text('Clear'),
              onPressed: _clearCanvas,
            )
          ]
          )
        ],
      ),
    );
  }
}
