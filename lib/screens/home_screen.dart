import 'package:flutter/material.dart';
import '../models/sudoku_game.dart';
import '../services/sudoku_service.dart';
import 'sudoku_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasOngoingGame = false;
  String? savedGameDifficulty;
  int selectedDifficulty = 1; // 默认选择1级难度

  @override
  void initState() {
    super.initState();
    // 检查是否有保存的游戏
    hasOngoingGame = SudokuService.hasSavedGame();
    if (hasOngoingGame) {
      final savedGame = SudokuService.getSavedGame();
      if (savedGame != null) {
        savedGameDifficulty = savedGame.difficulty;
      }
    }
  }

  void _startNewGame() async {
    // 根据滑动条的值获取对应的难度
    GameDifficulty difficulty = GameDifficulty.values[selectedDifficulty - 1];
    _startNewGameWithDifficulty(difficulty);
  }
  
  void _startNewGameWithDifficulty(GameDifficulty difficulty) async {
    // 保存游戏状态
    setState(() {
      hasOngoingGame = true;
      savedGameDifficulty = difficulty.displayName;
    });
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuScreen(difficulty: difficulty.displayName),
      ),
    );
    
    // 处理游戏结束的返回值
    if (result == 'completed') {
      // 游戏完成，清除保存的游戏状态
      setState(() {
        hasOngoingGame = false;
        savedGameDifficulty = null;
      });
    } else if (result == 'restart') {
      // 用户选择再来一局，立即开始同难度的新游戏
      _startNewGameWithDifficulty(difficulty);
    }
  }

  void _restartGame() {
    setState(() {
      hasOngoingGame = false; // 清除当前游戏状态，显示难度选择界面
      savedGameDifficulty = null;
    });
    // 清除保存的游戏
    SudokuService.clearSavedGame();
  }

  void _continueGame() async {
    if (savedGameDifficulty != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SudokuScreen(
            difficulty: savedGameDifficulty!,
            isResuming: true,
          ),
        ),
      );
      
      // 处理游戏结束的返回值
      if (result == 'completed') {
        // 游戏完成，清除保存的游戏状态
        setState(() {
          hasOngoingGame = false;
          savedGameDifficulty = null;
        });
      } else if (result == 'restart') {
        // 用户选择再来一局，清除当前游戏并开始同难度的新游戏
        SudokuService.clearSavedGame();
        // 找到对应的难度
        final difficulty = GameDifficulty.values.firstWhere(
          (d) => d.displayName == savedGameDifficulty,
          orElse: () => GameDifficulty.level1,
        );
        setState(() {
          hasOngoingGame = false;
          savedGameDifficulty = null;
        });
        _startNewGameWithDifficulty(difficulty);
      }
    }
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