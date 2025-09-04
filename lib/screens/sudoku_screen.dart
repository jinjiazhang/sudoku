import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sudoku_game.dart';
import '../services/sudoku_service.dart';

class SudokuScreen extends StatefulWidget {
  final String difficulty;
  final bool isResuming;

  const SudokuScreen({
    super.key,
    required this.difficulty,
    this.isResuming = false,
  });

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late SudokuGame _game;
  late SudokuService _sudokuService;
  late Timer _gameTimer;
  
  int selectedRow = -1;
  int selectedCol = -1;
  int selectedNumber = 0;
  bool isNoteMode = false;
  
  @override
  void initState() {
    super.initState();
    _sudokuService = SudokuService();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _game = _sudokuService.createSampleGame(
      widget.difficulty,
      isResuming: widget.isResuming,
    );
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _game = _game.copyWith(secondsElapsed: _game.secondsElapsed + 1);
      });
    });
  }

  void _selectCell(int row, int col) {
    if (!_game.isFixed[row][col]) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _inputNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.placeNumber(_game, selectedRow, selectedCol, number);
        selectedNumber = number;
        
        // 检查游戏是否完成
        if (_sudokuService.isGameComplete(_game)) {
          _gameTimer.cancel();
          _showGameCompleteDialog();
        }
      });
    }
  }

  void _eraseCell() {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.eraseCell(_game, selectedRow, selectedCol);
      });
    }
  }

  void _undoMove() {
    // TODO: 实现撤消功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('撤消功能待实现')),
    );
  }

  void _toggleNoteMode() {
    setState(() {
      isNoteMode = !isNoteMode;
    });
  }

  void _showHint() {
    if (selectedRow != -1 && selectedCol != -1) {
      final hints = _sudokuService.getHint(_game, selectedRow, selectedCol);
      if (hints.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('可能的数字: ${hints.join(', ')}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('该位置已固定或无有效提示')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个单元格')),
      );
    }
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('恭喜！'),
          content: Text(
            '游戏完成！\n用时: ${_sudokuService.formatTime(_game.secondsElapsed)}\n错误: ${_game.mistakes}次',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回主界面
              },
              child: const Text('返回主页'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _game.score.toString(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              // TODO: 打开游戏设置
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 游戏信息栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '难度',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _game.difficulty,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        '错误',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${_game.mistakes}/3',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '时间',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _sudokuService.formatTime(_game.secondsElapsed),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 数独网格 - 使用 Expanded 并设置 AspectRatio
            Expanded(
              flex: 6,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        int row = index ~/ 9;
                        int col = index % 9;
                        bool isSelected = row == selectedRow && col == selectedCol;
                        bool isHighlighted = row == selectedRow || col == selectedCol ||
                            (row ~/ 3 == selectedRow ~/ 3 && col ~/ 3 == selectedCol ~/ 3);
                        
                        return GestureDetector(
                          onTap: () => _selectCell(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.blue[100]
                                  : isHighlighted 
                                      ? Colors.blue[50] 
                                      : Colors.white,
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: _game.board[row][col] != 0
                                  ? Text(
                                      _game.board[row][col].toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _game.isFixed[row][col] 
                                            ? Colors.black 
                                            : Colors.blue,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // 工具栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: Icons.undo,
                    label: '撤消',
                    onPressed: _undoMove,
                  ),
                  _buildToolButton(
                    icon: Icons.brush,
                    label: '擦除',
                    onPressed: _eraseCell,
                  ),
                  _buildToolButton(
                    icon: Icons.edit,
                    label: '备注',
                    isActive: isNoteMode,
                    activeText: 'OFF',
                    onPressed: _toggleNoteMode,
                  ),
                  _buildToolButton(
                    icon: Icons.lightbulb_outline,
                    label: '提示',
                    badgeCount: 1,
                    onPressed: _showHint,
                  ),
                ],
              ),
            ),
            
            // 数字输入键盘
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(9, (index) {
                  int number = index + 1;
                  return GestureDetector(
                    onTap: () => _inputNumber(number),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selectedNumber == number 
                            ? Colors.blue 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: selectedNumber == number 
                                ? Colors.white 
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    String? activeText,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: isActive && activeText != null
                    ? Text(
                        activeText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        icon,
                        color: Colors.grey[600],
                        size: 20,
                      ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}