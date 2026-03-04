import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:flutter/material.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/host_list_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/requested_host_list_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/search_host_history.dart';
import 'package:get/get.dart';

class HostsView extends StatefulWidget {
  final int? agentUserId;

  const HostsView({super.key, this.agentUserId});

  @override
  State<HostsView> createState() => _HostsViewState();
}

class _HostsViewState extends State<HostsView> {
  late BusinessController _businessController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _businessController = Get.put(BusinessController());
  }

  @override
  void dispose() {
    super.dispose();
    _businessController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Host List ${widget.agentUserId != null ? '(AgentUid: ${widget.agentUserId})' : ''}',
            ),
            bottom: TabBar(
              labelColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(
                  icon: Icon(Icons.group),
                  text: "Hosts",
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: Icon(Icons.search),
                  text: "History",
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: Icon(Icons.group_add),
                  text: "Requested",
                  iconMargin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HostListView(agentUserId: widget.agentUserId),
              SearchHostHistory(agentUserId: widget.agentUserId),
              RequestedHostListView(agentUserId: widget.agentUserId),
            ],
          ),
        ),
      ),
    );
  }
}
