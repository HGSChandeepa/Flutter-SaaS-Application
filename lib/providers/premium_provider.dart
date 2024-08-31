import 'package:flutter/material.dart';
import 'package:langvify/services/stripe/stripe_storeage.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> checkPremiumStatus() async {
    _isPremium = await StripeStorage().checkIfUserIsPremium();
    notifyListeners();
  }

  void activatePremium() {
    _isPremium = true;
    notifyListeners();
  }
}
