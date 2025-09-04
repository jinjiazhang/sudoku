import 'package:flutter/material.dart';
import '../models/sudoku_game.dart';
import 'sudoku_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasOngoingGame = false;
  String ongoingGameDifficulty = '简单';
  String ongoingGameTime = '00:35';
  int selectedDifficulty = 1; // 默认选择1级难度

  @override
  void initState() {
    super.initState();
    hasOngoingGame = true;
  }

  void _startNewGame() {
    // 根据滑动条的值获取对应的难度
    GameDifficulty difficulty = GameDifficulty.values[selectedDifficulty - 1];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuScreen(difficulty: difficulty.displayName),
      ),
    );
  }

  void _restartGame() {
    setState(() {
      hasOngoingGame = false; // 清除当前游戏状态，显示难度选择界面
    });
  }

  void _continueGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuScreen(
          difficulty: ongoingGameDifficulty,
          isResuming: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              const Text(
                'Sudoku',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // 根据是否有正在进行的游戏显示不同界面
              if (hasOngoingGame) ...[
                // 有正在进行的游戏：显示继续游戏和重新开始按钮
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: _continueGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '继续游戏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '重新开始',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // 没有正在进行的游戏：显示难度选择和开始游戏按钮
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '难度: $selectedDifficulty',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2196F3),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: const Color(0xFF2196F3),
                        overlayColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      ),
                      child: Slider(
                        value: selectedDifficulty.toDouble(),
                        min: 1.0,
                        max: 9.0,
                        divisions: 8,
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value.round();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '开始游戏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}