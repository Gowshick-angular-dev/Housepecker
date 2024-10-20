// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:rive/components.dart';
// import 'package:rive/rive.dart';
// import 'package:rive/components.dart';
// import 'package:rive/rive.dart';
// import 'package:rive/src/rive_core/component.dart';
// import '../settings.dart';
// import '../utils/constant.dart';
//
// class BooleanProvider with ChangeNotifier {
//   final TickerProvider vsync;
//   BooleanProvider(this.vsync);
//
//   Artboard? artboard;
//   SMIBool? isReverse;
//   StateMachineController? _controller;
//   Map<String, dynamic> riveConfig = AppSettings.riveAnimationConfigurations;
//   late var addButtonConfig = riveConfig['add_button'];
//   late var artboardName = addButtonConfig['artboard_name'];
//   late var stateMachine = addButtonConfig['state_machine'];
//   late var booleanName = addButtonConfig['boolean_name'];
//   late var booleanInitialValue = addButtonConfig['boolean_initial_value'];
//   late var addButtonShapeName = addButtonConfig['add_button_shape_name'];
//
//   ///Animation for sell and rent button
//   late final AnimationController forSellAnimationController =
//   AnimationController(
//     vsync: vsync,
//     duration: const Duration(
//       milliseconds: 400,
//     ),
//     reverseDuration: const Duration(
//       milliseconds: 400,
//     ),
//   );
//   late final AnimationController forPropAnimationController =
//   AnimationController(
//     vsync: vsync,
//     duration: const Duration(
//       milliseconds: 500,
//     ),
//     reverseDuration: const Duration(
//       milliseconds: 500,
//     ),
//   );
//   late final AnimationController forRentController = AnimationController(
//     vsync: vsync,
//     duration: const Duration(milliseconds: 300),
//     reverseDuration: const Duration(milliseconds: 300),
//   );
//
//   ///END: Animation for sell and rent button
//   late final Animation<double> sellTween = Tween<double>(begin: -50, end: 80)
//       .animate(CurvedAnimation(
//       parent: forSellAnimationController, curve: Curves.easeIn));
//   late final Animation<double> propTween = Tween<double>(begin: -50, end: 130)
//       .animate(CurvedAnimation(
//       parent: forPropAnimationController, curve: Curves.easeIn));
//   late final Animation<double> rentTween = Tween<double>(begin: -50, end: 30)
//       .animate(
//       CurvedAnimation(parent: forRentController, curve: Curves.easeIn));
//
//
//   void initRiveAddButtonAnimation() {
//     ///Open file
//     rootBundle
//         .load("assets/riveAnimations/${Constant.riveAnimation}")
//         .then((value) {
//       ///Import that data to this method below
//       RiveFile riveFile = RiveFile.import(value);
//
//       ///Artboard by name you can check https://rive.app and learn it for more information
//       /// Here Add is artboard name from that workspace
//       artboard = riveFile.artboardByName(artboardName);
//       artboard?.forEachComponent((child) {
//         if (child.name == "plus") {
//           for (Component element in (child as Node).children) {
//             if (element.name == "Path_49") {
//               if (element is Shape) {
//                 final Shape shape = element;
//
//                 shape.fills.first.paint.color = Colors.white;
//               }
//             }
//           }
//         }
//         if (child is Shape && child.name == addButtonShapeName) {
//           final Shape shape = child;
//           shape.fills.first.paint.color = Colors.white;
//         }
//       });
//
//       ///in rive there is state machine to control states of animation, like. walking,running, and more
//       ///click is state machine name
//       _controller =
//           StateMachineController.fromArtboard(artboard!, stateMachine);
//       // _controller.
//       if (_controller != null) {
//         artboard?.addController(_controller!);
//
//         //this SMI means State machine input, we can create conditions in rive , so isReverse is boolean value name from there
//         isReverse = _controller?.findSMI(booleanName);
//
//         ///this is optional it depends on your conditions you can change this whole conditions and values,
//         ///for this animation isReverse =true means it will play its idle animation
//         isReverse?.value = booleanInitialValue;
//
//         ///here we can change color of any shape, here 'shape' is name in rive.app file
//       }
//       notifyListeners();
//     });
//   }
// }
