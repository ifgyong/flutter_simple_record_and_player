import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_record_and_player/fluttersimplerecordandplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String path = '';

  AudioPlayer _audioPlayer;

  String currentTime = '0:0';
  String allTime = '0:0';

  SimpleSoundRecordAndPlayer _recordAndPlayer;

  Duration allDate;
  @override
  void initState() {
    super.initState();
    _recordAndPlayer = SimpleSoundRecordAndPlayer();
    _recordAndPlayer.onAudioPlayerPositionChanged.listen((event) {
      setState(() {
        currentTime = '${event.inMinutes}:${event.inSeconds}';
      });
    });

    _audioPlayer = new AudioPlayer();
    _audioPlayer.onAudioPositionChanged.listen((duration) {
      setState(() {
        currentTime = '${duration.inMinutes}\'${duration.inSeconds % 60}\'\'';
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((event) {
      print('状态变更：${event.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      type: MaterialType.card,
      home: Scaffold(
        appBar: AppBar(
          title: Text('title'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  try {
                    _recordAndPlayer.startRecord(null, (error) {
                      print(error);
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('开始'),
              ),
              FlatButton(
                onPressed: () async {
                  bool s = _recordAndPlayer.stopRecord;
                  print('结束:$s');
                },
                child: Text('结束'),
              ),
              Text(path),
              FlatButton(
                onPressed: () async {
                  String s = _recordAndPlayer.recordListPath.last;
                  print('mp3URL:$s');
                  _recordAndPlayer.play(s, isLocal: true);
                },
                child: Text('play'),
              ),
              FlatButton(
                onPressed: () async {
//                  bool s = await RecordMp3.instance.stop();
//                  _audioPlayer?.pause();
                  _recordAndPlayer?.pausePlay();
                },
                child: Text('暂停'),
              ),
              FlatButton(
                onPressed: () async {
//                  bool s = await RecordMp3.instance.stop();
                  _recordAndPlayer?.stopPlay();
                },
                child: Text('结束'),
              ),
              Text('$currentTime/${_recordAndPlayer?.duration}'),
              Text(
                  '$currentTime/${_audioPlayer?.duration.inMinutes}\'${_audioPlayer?.duration.inSeconds % 60}\'\''),
              FlatButton(
                onPressed: () async {
                  _recordAndPlayer.play(
                      'http://music.163.com/song/media/outer/url?id=1447126763.mp3',
                      isLocal: false);
                },
                child: Text('播放网络语音'),
              ),
              FlatButton(
                onPressed: () async {
                  final f = await _recordAndPlayer.getRecordLastData;
                  print('$f');
                },
                child: Text('输出最后文件'),
              ),
              FlatButton(
                onPressed: () async {
                  _recordAndPlayer.clearDiskCache();
                },
                child: Text('清空文件目录'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  Future<String> _createPath() async {
    String p = await _getPath();
    final date = DateTime.now();

    final directory = Directory(p);
    if (directory.existsSync() == false) {
      final success = await directory.create();
      if (success != null) {
        return '$p/${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}.mp3';
      }
    }
    return '$p/${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}.mp3';
  }

  Future<String> _getPath() async {
    final p = await getTemporaryDirectory();
    print(p);
    return p.path + '/mp3';
  }

  void _play(String path) {}
}
