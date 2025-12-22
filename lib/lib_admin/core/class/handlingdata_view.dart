import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'statusrequest.dart';
import '../constant/imageassets.dart';
class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;
  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.widget,
  });
  @override
  Widget build(BuildContext context) {
    switch (statusRequest) {
      case StatusRequest.loading:
        return const Center(child: CircularProgressIndicator());
      case StatusRequest.offlineFailure:
        return Center(child: Lottie.asset(AppImageAsset.offline));
      case StatusRequest.serverFailure:
        return Center(child: Lottie.asset(AppImageAsset.serverfailure));
      case StatusRequest.failure:
        return Center(child: Lottie.asset(AppImageAsset.nodata));
      default:
        return widget;
    }
  }
}
