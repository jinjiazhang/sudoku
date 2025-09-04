import 'package:flutter/material.dart';
import '../models/sudoku_game.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '选择难度',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // 使用网格显示9个难度等级
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: GameDifficulty.values.map((difficulty) {
                return _buildDifficultyButton(
                  context: context,
                  difficulty: difficulty,
                  onTap: () => Navigator.of(context).pop(difficulty.displayName),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '取消',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  Widget _buildDifficultyButton({
    required BuildContext context,
    required GameDifficulty difficulty,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: difficulty.color.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: difficulty.color.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              difficulty.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: difficulty.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              difficulty.description,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}