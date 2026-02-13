// import 'package:flutter/material.dart';
// import 'package:vgs/controllers/radio_controller.dart';

// class VolumeSlider extends StatefulWidget {
//   const VolumeSlider({super.key});

//   @override
//   State<VolumeSlider> createState() => _VolumeSliderState();
// }

// class _VolumeSliderState extends State<VolumeSlider> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.volume_mute,
//             size: 30,
//             color: Colors.black,
//           ),
//           Flexible(
//             child: SliderTheme(
//               data: const SliderThemeData(
//                 thumbColor: Colors.tealAccent,
//                 activeTrackColor: Color.fromARGB(255, 130, 199, 192),
//                 inactiveTrackColor: Colors.teal,
//               ),
//               child: Slider(
//                 value: radioController.volume,
//                 min: 0,
//                 max: 100,
//                 divisions: 100,
//                 label: radioController.volume.round().toString(),
//                 onChanged: (double value) {
//                   setState(() {
//                     radioController.volume = value;
//                   });
//                 },
//               ),
//             ),
//           ),
//           const Icon(
//             Icons.volume_up,
//             color: Colors.black,
//             size: 30,
//           ),
//         ],
//       ),
//     );
//   }
// }
