import 'package:get/get.dart';
import 'details_controller.dart';

class DetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DetailsController>(DetailsController());
  }
}
