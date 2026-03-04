import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:flutter/material.dart';
import 'package:doyel_live/app/modules/business/views/reseller/reseller_recharge_history_list_view.dart';
import 'package:doyel_live/app/modules/business/views/reseller/reseller_recharge_view.dart';
import 'package:get/get.dart';

class ResellerView extends StatefulWidget {
  @override
  State<ResellerView> createState() => _ResellerViewState();
}

class _ResellerViewState extends State<ResellerView> {
  late BusinessController _businessController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _businessController = Get.put(BusinessController());
  }

  @override
  void dispose() {
    _businessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reseller Activity'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.diamond),
                  text: "Recharge",
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: "Histories",
                  iconMargin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ResellerRechargeView(),
              ResellerRechargeHistoryListView(),
            ],
          ),
        ),
      ),
    );
  }
}
