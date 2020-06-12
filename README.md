
## install

```
flutter_simple_record_and_player: ^1.0.0+0.1
```

## config iOS Info.plist
iOS 
Make sure you add the following key to Info.plist for iOS

```
<key>NSMicrophoneUsageDescription</key>
<string>xxxxxx</string>

```

## Example
[github Example code](https://github.com/ifgyong/flutter_simple_record_and_player/blob/master/expamle/lib/main.dart)

```
  SimpleSoundRecordAndPlayer _recordAndPlayer = new SimpleSoundRecordAndPlayer();

```

### 录音
```
try {
    String path='/cached/demo.mp3';
    _recordAndPlayer.startRecord(path, (error) {
                      print(error);
         });
      } catch (e) {
                  print(e);
              }
        },
```
### 结束录音

```
_recordAndPlayer.stopRecord;
```
### 获取录音的最新路径
```
_recordAndPlayer.recordListPath.last
```

### 播放文件

```
_recordAndPlayer.play(s, isLocal: true);
```

### 暂停播放
```
 _recordAndPlayer?.pausePlay();

```

### 结束播放

```
_recordAndPlayer?.stopPlay();
```

### 播放网络音频

```
_recordAndPlayer.play(
                      'http://music.163.com/song/media/outer/url?id=1447126763.mp3',
                      isLocal: false)
```

### 清空录好的文件

```
_recordAndPlayer.clearDiskCache();
```

### 录音进度监听
```
 _recordAndPlayer.onAudioPlayerPositionChanged.listen((event) {
      setState(() {
        currentTime = '${event.inMinutes}:${event.inSeconds}';
      });
    });
```
### 播放器状态变更

```
 _audioPlayer.onPlayerStateChanged.listen((event) {
      print('状态变更：${event.toString()}');
    });
```


