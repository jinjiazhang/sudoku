import 'package:flutter/material.dart';
import 'dart:async';

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
  late List<List<int>> board;
  late List<List<bool>> isFixed;
  int selectedRow = -1;
  int selectedCol = -1;
  int selectedNumber = 0;
  int mistakes = 0;
  int score = 0;
  late Timer gameTimer;
  int secondsElapsed = 0;
  bool isNoteMode = false;
  bool showHints = true;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    board = List.generate(9, (i) => List.generate(9, (j) => 0));
    isFixed = List.generate(9, (i) => List.generate(9, (j) => false));
    
    // 模拟一个数独棋盘（基于设计图中的布局）
    _loadSampleBoard();
    
    if (widget.isResuming) {
      secondsElapsed = 35; // 模拟继续游戏的时间
    }
  }

  void _loadSampleBoard() {
    // 基于设计图片中的数独布局
    List<List<int>> sampleBoard = [
      [0, 0, 2, 7, 0, 1, 0, 0, 6],
      [0, 0, 0, 6, 9, 0, 0, 1, 0],
      [9, 6, 0, 0, 8, 0, 5, 3, 0],
      [9, 8, 4, 0, 0, 0, 6, 4, 0],
      [2, 0, 0, 0, 0, 0, 0, 0, 0],
      [6, 0, 3, 0, 5, 8, 0, 0, 0],
      [0, 7, 8, 0, 1, 4, 9, 0, 0],
      [4, 2, 0, 3, 6, 7, 0, 0, 5],
      [5, 0, 1, 0, 0, 9, 3, 0, 4],
    ];
    
    List<List<bool>> fixedCells = [
      [false, false, true, true, false, true, false, false, true],
      [false, false, false, true, true, false, false, true, false],
      [true, true, false, false, true, false, true, true, false],
      [true, true, true, false, false, false, true, true, false],
      [true, false, false, false, false, false, false, false, false],
      [true, false, true, false, true, true, false, false, false],
      [false, true, true, false, true, true, true, false, false],
      [true, true, false, true, true, true, false, false, true],
      [true, false, true, false, false, true, true, false, true],
    ];
    
    board = sampleBoard.map((row) => row.toList()).toList();
    isFixed = fixedCells.map((row) => row.toList()).toList();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _selectCell(int row, int col) {
    if (!isFixed[row][col]) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _inputNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1 && !isFixed[selectedRow][selectedCol]) {
      setState(() {
        if (board[selectedRow][selectedCol] == number) {
          board[selectedRow][selectedCol] = 0;
        } else {
          board[selectedRow][selectedCol] = number;
        }
      });
    }
  }

  void _eraseCell() {
    if (selectedRow != -1 && selectedCol != -1 && !isFixed[selectedRow][selectedCol]) {
      setState(() {
        board[selectedRow][selectedCol] = 0;
      });
    }
  }

  void _undoMove() {
    // TODO: 实现撤消功能
  }

  void _toggleNoteMode() {
    setState(() {
      isNoteMode = !isNoteMode;
    });
  }

  void _showHint() {
    // TODO: 实现提示功能
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
          score.toString(),
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
      body: Column(
        children: [
          // 游戏信息栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.difficulty,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
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
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$mistakes/3',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
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
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatTime(secondsElapsed),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 数独网格
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
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
                        borderRadius: _getCellBorderRadius(row, col),
                      ),
                      child: Center(
                        child: board[row][col] != 0
                            ? Text(
                                board[row][col].toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isFixed[row][col] 
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
          
          // 工具栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(9, (index) {
                int number = index + 1;
                return GestureDetector(
                  onTap: () => _inputNumber(number),
                  child: Container(
                    width: 32,
                    height: 32,
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
                          fontSize: 20,
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
    );
  }

  BorderRadius _getCellBorderRadius(int row, int col) {
    return BorderRadius.circular(0);
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    String? activeText,
    int? badgeCount,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              child: isActive && activeText != null
                  ? Text(
                      activeText,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.grey[600],
                      size: 24,
                    ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}