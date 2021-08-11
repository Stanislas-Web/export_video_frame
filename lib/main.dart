import 'dart:io';

import 'package:export_video_frame/export_video_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String thumbNailImage = '';
  late VideoPlayerController _controller;
  var images = [];
  SfRangeValues dateValues = SfRangeValues(DateTime(2005, 01, 01), DateTime(2008, 01, 01));
  DateTime dateMin = DateTime(2003, 01, 01);
  DateTime dateMax = DateTime(2010, 01, 01);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/pub.mp4')
      ..initialize().then((_) {
        setState(() {
          Future.delayed(Duration.zero, () async {
            final byteData =
                await rootBundle.load("assets/videos/pub.mp4");
            Directory tempDir = await getTemporaryDirectory();

            File tempVideo = File("${tempDir.path}/assets/videos/pub.mp4")
              ..createSync(recursive: true)
              ..writeAsBytesSync(byteData.buffer
                  .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)); 
            var duration = _controller.value.duration;
            print(duration);
            var image = await ExportVideoFrame.exportImageBySeconds(
                tempVideo, Duration(seconds: 3), 0);
            dateValues = SfRangeValues(0, duration.inSeconds);
           
            thumbNailImage = image.path;
            int secondes = duration.inSeconds;
            var temp = 0;
            int sec = (secondes /10).toInt();
            for (var i = 0; i< 10; i++){
                if(i == 0){
                  var image = await ExportVideoFrame.exportImageBySeconds(
                  tempVideo, Duration(seconds: sec), 0);
                  images.add(image.path);
                }else{                              
                  temp = sec + (secondes /10).toInt();
                  var image = await ExportVideoFrame.exportImageBySeconds(
                  tempVideo, Duration(seconds: temp), 0);
                  images.add(image.path);
                  sec = sec + (secondes /10).toInt();
                }
            }
            print(images);
            print("file name = $thumbNailImage video duration = ${_controller.value.duration.inMilliseconds}");
            setState(() {});
          });
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black, 
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Center(child: const Icon(Icons.send, color: Colors.white,)),
      backgroundColor: Colors.red[500],
    ),
    body:Container(
      margin: EdgeInsets.only(top:250, bottom:150),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height ,
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    bottomNavigationBar:SfRangeSelector(
              initialValues: dateValues,
              min: dateMin,
              max: dateMax,
              activeColor: Colors.red,
              inactiveColor: Colors.black.withOpacity(0.5),
              child: Container(
              height: 45,
              margin: EdgeInsets.symmetric(vertical:10),
              decoration: BoxDecoration(
                border:Border.all(
                  color:Colors.black
                )
              ) ,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return Container(
                  width: 34,
                  decoration: BoxDecoration(
                    border: Border.all(color:Colors.black)
                  ),
                  child: Image.file(File(images[index]),fit: BoxFit.cover,));
                },
              ),
          ),
        ),
    );
  }
}