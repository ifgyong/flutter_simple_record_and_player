import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

class SimpleSoundRecordAndPlayer {
  AudioPlayer _audioPlayer;
  RecordMp3 _recordMp3;

  List<String> _paths;

  /// 简单的录音和播放音频库
  SimpleSoundRecordAndPlayer() {
    _audioPlayer = AudioPlayer();
    _recordMp3 = RecordMp3.instance;
    _paths = new List();
  }

  /// 获取录音控件
  RecordMp3 get recordMp3 => _recordMp3;

  /// 获取播放器控件
  AudioPlayer get audioPlayer => _audioPlayer;

  /// 播放器
  /// 播放器 状态变更
  Stream<AudioPlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  /// 播放进度
  Stream<Duration> get onAudioPlayerPositionChanged =>
      _audioPlayer.onAudioPositionChanged;
  RecordStatus get recordStatus => _recordMp3.status;

  /// 播放 url
  /// isLocal 支持[remote] 和[local]
  ///
  Future<void> play(String url, {bool isLocal = false}) async {
    await _audioPlayer.play(url, isLocal: isLocal);
  }

  /// 停止当前播放.
  Future<void> pausePlay() async => await _audioPlayer.pause();

  /// 停止播放器
  Future<void> stopPlay() async => await _audioPlayer.stop();

  /// 播放器 静音
  Future<void> mutePlay(bool muted) async => await _audioPlayer.mute(muted);

  /// 播放器 选择时间段进行播放
  Future<void> seekPlay(double seconds) async =>
      await _audioPlayer.seek(seconds);

  /// 播放器 时间周期长度
  Duration get duration => _audioPlayer.duration;

  /// 获取录音存储的路径数组
  List<String> get recordListPath => _paths;

  /// 获取最后一次录音的文件
  Future<Uint8List> get getRecordLastData async {
    if (_paths != null && _paths.length > 0) {
      if (true) {
        final file = File(_paths.last);
        if (file.existsSync()) {
          return await file.readAsBytes();
        }
        return null;
      } else {
        throw new ArgumentError.value(
            'MediaLibrary Permission rejected by user');
      }
    }
    return null;
  }

  /// 开始录音 path是路径 最好是cahed文件夹 推荐使用 [path_provider]
  /// 路径是空的话 默认创建问价夹sound/**.mp3
  /// 如果 [path=null]，则会默认创建一个[path]
  /// 如果用户禁止录音权限，则会抛出错误[用户禁止了录音功能]
  void startRecord(String path, Function(RecordErrorType) onRecordError) async {
    bool permission = await checkPermission();
    if (permission) {
      path ??= await _createFile();
      _paths ??= new List();
      _paths.add(path);
      _recordMp3.start(path, onRecordError);
    } else {
      throw new ArgumentError.value('用户禁止了录音功能');
    }
  }

  /// 检查是否 获取权限 记得 使用 [permission_handler]
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  /// 检查是否 获取音视频权限 记得 使用 [permission_handler]
  Future<bool> checkPermissionMediaLibrary() async {
    if (!await Permission.mediaLibrary.isGranted) {
      PermissionStatus status = await Permission.mediaLibrary.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  /// 录音机
  /// 暂停录音
  bool get pauseRecord => _recordMp3.pause();

  /// 停止录音
  bool get stopRecord => _recordMp3.stop();

  /// 清除缓存
  /// 默认目录是[Caches/sound]
  /// 全部清空
  Future<bool> clearDiskCache() async {
    try {
      String path = await _getPath();
      Directory d = Directory(path);
      int length = await d.list().length;

      /// 当文件目录不为空时删除
      if (length > 0) {
        d.delete(recursive: true);
      }
      d.list().forEach((element) {
        print(element.path);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 创建文件
  /// 默认路径是[Caches/sound]
  /// 文件命名是[yyyyMMDDHHddss]
  Future<String> _createFile() async {
    String p = await _getPath();
    final date = DateTime.now();

    final directory = Directory(p);
    if (directory.existsSync() == false) {
      final success = await directory.create(recursive: true);
      if (success != null) {
        return '$p/${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}.mp3';
      } else {
        throw new ArgumentError.value('create sound path faild!');
      }
    }
    return '$p/${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}.mp3';
  }

  /// 文件存储目录
  Future<String> _getPath() async {
    final p = await getTemporaryDirectory();
    return p.path + '/sound';
  }
}
