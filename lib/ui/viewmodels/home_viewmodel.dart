import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void init() {
    _currentTabIndex = 0;
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
