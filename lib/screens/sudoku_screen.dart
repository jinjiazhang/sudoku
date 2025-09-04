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
    if (widget.isResuming) {
      // 尝试加载保存的游戏
      final savedGame = SudokuService.getSavedGame();
      if (savedGame != null) {
        _game = savedGame;
        return;
      }
    }
    
    // 创建新游戏
    GameDifficulty? difficulty = _getDifficultyFromName(widget.difficulty);
    if (difficulty != null) {
      _game = _sudokuService.createNewGame(difficulty);
    } else {
      // 如果找不到对应难度，使用Level 1作为默认值
      _game = _sudokuService.createNewGame(GameDifficulty.level1);
    }
    
    // 保存新创建的游戏
    SudokuService.saveGame(_game);
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _game = _game.copyWith(secondsElapsed: _game.secondsElapsed + 1);
        // 每秒保存游戏状态
        SudokuService.saveGame(_game);
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
        
        // 保存游戏状态
        SudokuService.saveGame(_game);
        
        // 检查游戏是否完成
        if (_sudokuService.isGameComplete(_game)) {
          _gameTimer.cancel();
          SudokuService.clearSavedGame(); // 游戏完成时清除保存
          _showGameCompleteDialog();
        }
      });
    }
  }

  void _eraseCell() {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.eraseCell(_game, selectedRow, selectedCol);
        // 保存游戏状态
        SudokuService.saveGame(_game);
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
                Navigator.of(context).pop('completed'); // 返回主界面，标记游戏完成
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
                  child: _buildSudokuGrid(),
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
              child: _buildNumberKeyboard(),
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

  /// 构建数字键盘，根据游戏难度显示不同数量的数字
  Widget _buildNumberKeyboard() {
    GameDifficulty? difficulty = _getDifficultyFromName(_game.difficulty);
    int numberRange = difficulty?.numberRange ?? 9;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(numberRange, (index) {
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
    );
  }

  /// 从难度名称获取难度枚举
  GameDifficulty? _getDifficultyFromName(String difficultyName) {
    for (GameDifficulty difficulty in GameDifficulty.values) {
      if (difficulty.displayName == difficultyName) {
        return difficulty;
      }
    }
    return null;
  }

  /// 判断单元格是否需要高亮显示
  bool _isHighlightedCell(int row, int col) {
    if (selectedRow == -1 || selectedCol == -1) return false;
    
    // 高亮同行、同列的单元格
    if (row == selectedRow || col == selectedCol) return true;
    
    // 高亮同子区域的单元格
    return _isInSameSubRegion(row, col, selectedRow, selectedCol);
  }

  /// 判断两个单元格是否在同一子区域
  bool _isInSameSubRegion(int row1, int col1, int row2, int col2) {
    switch (_game.gridSize) {
      case 4:
        // 2x2子区域
        return (row1 ~/ 2 == row2 ~/ 2) && (col1 ~/ 2 == col2 ~/ 2);
      case 6:
        // 2x3子区域（6x6数独有6个2x3子区域，排列为3行2列）
        return (row1 ~/ 2 == row2 ~/ 2) && (col1 ~/ 3 == col2 ~/ 3);
      case 9:
      default:
        // 3x3子区域
        return (row1 ~/ 3 == row2 ~/ 3) && (col1 ~/ 3 == col2 ~/ 3);
    }
  }



  /// 获取自适应字体大小
  double _getCellFontSize() {
    switch (_game.gridSize) {
      case 4:
        return 28.0;  // 4x4网格较大字体
      case 6:
        return 22.0;  // 6x6网格中等字体
      case 9:
      default:
        return 16.0;  // 9x9网格较小字体
    }
  }

  /// 构建数独网格，包含正确的边框样式
  Widget _buildSudokuGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildSubGridLayout(),
      ),
    );
  }

  /// 构建子网格布局
  Widget _buildSubGridLayout() {
    if (_game.gridSize == 6) {
      return _build6x6Grid();
    }
    
    int subGridSize = _getSubGridSize();
    int subGridCount = _game.gridSize ~/ subGridSize;

    return Column(
      children: List.generate(subGridCount, (subGridRow) {
        return Expanded(
          child: Row(
            children: List.generate(subGridCount, (subGridCol) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: subGridCol < subGridCount - 1 
                          ? const BorderSide(color: Colors.black, width: 2)
                          : BorderSide.none,
                      bottom: subGridRow < subGridCount - 1
                          ? const BorderSide(color: Colors.black, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: _buildSubGrid(subGridRow, subGridCol),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// 专门为6x6网格构建布局（3行2列的2x3子网格）
  Widget _build6x6Grid() {
    return Column(
      children: [
        // 第1行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左上子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(0, 0),
                ),
              ),
              // 右上子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(0, 1),
                ),
              ),
            ],
          ),
        ),
        // 第2行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左中子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(1, 0),
                ),
              ),
              // 右中子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(1, 1),
                ),
              ),
            ],
          ),
        ),
        // 第3行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左下子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(2, 0),
                ),
              ),
              // 右下子网格 (2x3)
              Expanded(
                flex: 3,
                child: _build2x3SubGrid(2, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建2x3子网格
  Widget _build2x3SubGrid(int subGridRow, int subGridCol) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemCount: 6, // 2x3 = 6个单元格
      itemBuilder: (context, index) {
        int localRow = index ~/ 3;
        int localCol = index % 3;
        
        int globalRow = subGridRow * 2 + localRow;
        int globalCol = subGridCol * 3 + localCol;
        
        bool isSelected = globalRow == selectedRow && globalCol == selectedCol;
        bool isHighlighted = _isHighlightedCell(globalRow, globalCol);
        
        return GestureDetector(
          onTap: () => _selectCell(globalRow, globalCol),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFBBDEFB)
                  : isHighlighted 
                      ? Colors.blue[50] 
                      : Colors.white,
              border: Border(
                right: localCol < 2
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
                bottom: localRow < 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: _game.board[globalRow][globalCol] != 0
                  ? Text(
                      _game.board[globalRow][globalCol].toString(),
                      style: TextStyle(
                        fontSize: _getCellFontSize(),
                        fontWeight: FontWeight.bold,
                        color: _game.isFixed[globalRow][globalCol] 
                            ? Colors.black 
                            : Colors.blue,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// 构建单个子网格
  Widget _buildSubGrid(int subGridRow, int subGridCol) {
    int subGridSize = _getSubGridSize();
    
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: subGridSize,
        childAspectRatio: 1.0,
      ),
      itemCount: subGridSize * subGridSize,
      itemBuilder: (context, index) {
        int localRow = index ~/ subGridSize;
        int localCol = index % subGridSize;
        
        int globalRow = subGridRow * subGridSize + localRow;
        int globalCol = subGridCol * subGridSize + localCol;
        
        bool isSelected = globalRow == selectedRow && globalCol == selectedCol;
        bool isHighlighted = _isHighlightedCell(globalRow, globalCol);
        
        return GestureDetector(
          onTap: () => _selectCell(globalRow, globalCol),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFBBDEFB) // 浅蓝色，匹配参考图
                  : isHighlighted 
                      ? Colors.blue[50] 
                      : Colors.white,
              border: Border(
                right: localCol < subGridSize - 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
                bottom: localRow < subGridSize - 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: _game.board[globalRow][globalCol] != 0
                  ? Text(
                      _game.board[globalRow][globalCol].toString(),
                      style: TextStyle(
                        fontSize: _getCellFontSize(),
                        fontWeight: FontWeight.bold,
                        color: _game.isFixed[globalRow][globalCol] 
                            ? Colors.black 
                            : Colors.blue,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// 获取子网格大小
  int _getSubGridSize() {
    switch (_game.gridSize) {
      case 4: return 2;  // 4x4 使用 2x2 子网格
      case 6: return 2;  // 6x6 使用 2x3 子网格（需要特殊处理）
      case 9: return 3;  // 9x9 使用 3x3 子网格
      default: return 3;
    }
  }
}