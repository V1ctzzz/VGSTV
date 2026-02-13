// import 'dart:ffi';

// import 'package:flutter/material.dart';
// import 'package:flutter_radio_player/flutter_radio_player.dart';
// import 'package:flutter_radio_player/models/frp_source_modal.dart';
// import 'package:vgs/configs/radio_config.dart';

// // late final RadioController radioController;

// class RadioController {
//   FlutterRadioPlayer? _frp = FlutterRadioPlayer();

//   bool _isPlaying = false;
//   bool _initialized = false;
//   // late final AppLifecycleListener _listener;
//   // double _volume = 1.0;

//   // double get volume => _volume * 100;

//   // set volume(double value) {
//   //   _volume = value / 100;
//   //   _frp?.setVolume(_volume);
//   // }

//   void Function(bool status) _onStatusChange = (status) => Void;

//   set onStatusChange(void Function(bool status) callback) {
//     _onStatusChange = callback;
//   }

//   RadioController() {
//     _frp ??= FlutterRadioPlayer();
//     // _listener = AppLifecycleListener(
//     //   onDetach: () {
//     //     print('detach');
//     //     dispose();
//     //   },
//     // );
//   }

//   void init() {
//     if (_initialized) {
//       if (!_isPlaying) play();
//       return;
//     }
//     _frp?.initPlayer();
//     _frp?.addMediaSources(FRPSource(mediaSources: [RadioConfig.source()]));
//     _frp?.setVolume(1.0);

//     // volume = 100.0;
//     // _isPlaying = true;
//     // play();
//     // if (!_isPlaying) {
//     //   _frp?.play();
//     // }
//     _isPlaying = true;
//     _initialized = true;
//   }

//   void dispose() {
//     print('dispose');
//     if (_frp == null) return;
//     _frp?.pause();

//     // _frp = FlutterRadioPlayer();
//     // _frp = null;
//     _onStatusChange = (status) => Void;
//     // _listener.dispose();
//   }

//   RadioController play() {
//     _frp?.play();
//     _isPlaying = true;
//     _onStatusChange(_isPlaying);
//     //outros eventos que quiser adicionar
//     return this;
//   }

//   RadioController pause() {
//     _frp?.pause();
//     _isPlaying = false;
//     _onStatusChange(_isPlaying);
//     //outros eventos que quiser adicionar
//     return this;
//   }

//   bool get isPlaying => _isPlaying;
// }
