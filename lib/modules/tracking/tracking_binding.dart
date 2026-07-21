import 'package:get/get.dart';
import 'tracking_controller.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TrackingController>(TrackingController());
  }
}
