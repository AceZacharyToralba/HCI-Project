import '../game/game_manager.dart';

class StoreItem {
  final String name;
  final int cost; 
  final Function(GameManager) applyEffect;
  bool isBought;

  StoreItem({
    required this.name,
    required this.cost,
    required this.applyEffect,
    this.isBought = false,
  });
}