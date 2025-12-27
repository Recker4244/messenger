import 'package:flutter/material.dart';
import 'package:sivi_chat/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/users_viewmodel.dart';
import '../users/users_view.dart';
import '../chats/chats_view.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});
  @override
  Widget builder(BuildContext context, HomeViewModel model, Widget? child) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                toolbarHeight: 30,
                pinned: model.currentTabIndex == 1 ? true : false,
                floating: model.currentTabIndex == 0 ? true : false,
                snap: model.currentTabIndex == 0 ? true : false,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    height: 60,
                    //width: double.infinity,
                    child: Center(
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepPurple[100],
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTabButton(
                                context,
                                model,
                                0,
                                'Users',
                                model.currentTabIndex == 0,
                              ),
                              _buildTabButton(
                                context,
                                model,
                                1,
                                'Chats',
                                model.currentTabIndex == 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: IndexedStack(
            index: model.currentTabIndex,
            children: [UsersView(), ChatsView()],
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  Widget _buildTabButton(
    BuildContext context,
    HomeViewModel model,
    int index,
    String label,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => model.setTabIndex(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
