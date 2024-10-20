// import 'package:rive/rive.dart';
//
// import '../exports/main_export.dart';
// import 'bottom_navigation_sim_event.dart';
// import 'bottom_navigation_sim_state.dart';
//
// class ToggleBloc extends Bloc<ToggleEvent, ToggleState> {
//   ToggleBloc(SMIBool? isReverse) : super(ToggleInitial(isReverse)) {
//     // Register event handlers
//     on<ToggleTrue>((event, emit) {
//       print("ToggleTrue event received");
//       if (state is ToggleInitial) {
//         final smiBool = (state as ToggleInitial).isReverse;
//         if (smiBool != null) {
//           smiBool.value = true;
//           emit(ToggleInitial(smiBool));
//         }
//       }
//     });
//
//     on<ToggleFalse>((event, emit) {
//       print("ToggleFalse event received");
//       if (state is ToggleInitial) {
//         final smiBool = (state as ToggleInitial).isReverse;
//         if (smiBool != null) {
//           smiBool.value = false;
//           emit(ToggleInitial(smiBool));
//         }
//       }
//     });
//   }
// }