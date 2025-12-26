import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../viewmodels/chats_viewmodel.dart';

class ChatsView extends StackedView<ChatsViewModel> {
  const ChatsView({super.key});
  @override
  ChatsViewModel viewModelBuilder(BuildContext context) => ChatsViewModel();
  @override
  Widget builder(BuildContext context, ChatsViewModel model, Widget? child) {
    return Scaffold(
      body: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: 30,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text(index.toString()),
            onTap: () {},
          );
        },
      ),
    );
  }
}
