import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../viewmodels/main_navigation_viewmodel.dart';
import '../home/home_view.dart';
import '../offers/offers_view.dart';
import '../settings/settings_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
    return ViewModelBuilder<MainNavigationViewModel>.reactive(
      viewModelBuilder: () => MainNavigationViewModel(),
      builder: (context, model, child) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Scaffold(
              body: IndexedStack(
                index: model.currentIndex,
                children: const [HomeView(), OffersView(), SettingsView()],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: model.currentIndex,
                onTap: (index) => model.setIndex(index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.local_offer),
                    label: 'Offers',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
