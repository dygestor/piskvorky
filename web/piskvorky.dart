import 'dart:html';
import 'dart:math' as math;

class Piskvorky {
  int _width;
  int _height;
  int _x;
  int _y;
  int _player;
  int _required_to_win;
  bool _end;
  String _container;
  Element _turn;
  Element _new_game_button;
  CanvasRenderingContext2D _context;
  
  List<List<int>> _plocha;
  
  Piskvorky(String container, int width, int height) {
    _width = width;
    _height = height;
    _container = container;
    _player = 1;
    _end = false;
    _required_to_win = 5;
    
    setupBoard();
    
    _turn = new Element.div();
    _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
    
    _new_game_button = new InputElement(type: "submit");
    _new_game_button.attributes['value'] = "New Game";
    
    addHtml();
    
    _context.canvas.onMouseUp.listen((e) {
      addPoint(e);
    });
    
    _new_game_button.onClick.listen((e) {
      _width = width;
      _height = height;
      _player = 1;
      _end = false;
      _required_to_win = 5;
      
      setupBoard();
      
      _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
      
      draw();
    });
  }
  
  void setupBoard() {
    _plocha = new List<List<int>>();
    
    for (int i = 0; i < _height; i++) {
      _plocha.add(new List<int>());
      for (int j = 0; j < _width; j++) {
        _plocha[i].add(0);
      }
    }  
  }
  
  void addPoint(MouseEvent e) {
    if (!_end) { 
      Point p = e.offset;
      int i = (p.y / _y).floor();
      int j = (p.x / _x).floor();
      
      if (_plocha[i][j] == 0) { 
        _plocha[i][j] = _player;
        check(i, j);
        
        if (_end) {
          _turn.innerHtml = "Player " + _player.toString() + " wins!";        
        } else {
          changePlayer();
        }
        if ((i == 0) || (i == _plocha.length - 1) || (j == 0) || (j == _plocha[i].length-1)) {
          addFields(i, j);
        }
        
        draw();
      }
    }
  }
  
  void addFields(int y, int x) {
    bool rowStart = (y == 0);
    bool rowEnd = (y == _plocha.length - 1);
    bool colStart = (x == 0);
    bool colEnd = (x == _plocha[y].length - 1);
    
    if (y == 0) {
      _plocha.insert(0, new List<int>());
      for (int i = 0; i < _width; i++) {
        _plocha[0].add(0);
      }
      _height++;
    } else if ((y == _plocha.length - 1) || colStart || colEnd) {
      _plocha.add(new List<int>());
      for (int i = 0; i < _width; i++) {
        _plocha[_plocha.length-1].add(0);
      }
      _height++;
    }
    
    if (x == 0) {
      for (int i = 0; i < _plocha.length; i++) {
        _plocha[i].insert(0, 0);
      }
      _width++;
    } else if (x == _plocha[y].length - 1 || rowStart || rowEnd) {
      for (int i = 0; i < _plocha.length; i++) {
        _plocha[i].add(0);
      }
      _width++;
    }
  }
  
  void changePlayer() {
    _player = (_player == 1) ? 2 : 1;
    _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
  }
  
  void addHtml() {
    querySelector(_container)
        ..append(_turn)
        ..append(_new_game_button)
        ..append(generateElement());
  }
  
  void check(int y, int x) {
    int count;
    //horizontally
    count = checkDirection(y, x, 0, -1) + checkDirection(y, x, 0, 1); 
    if (count == _required_to_win - 1) {
      _end = true;
      return;
    }
    
    //vertically
    count = checkDirection(y, x, -1, 0) + checkDirection(y, x, 1, 0); 
    if (count == _required_to_win - 1) {
      _end = true;
      return;
    } 
    
    //diagonally 1
    count = checkDirection(y, x, -1, -1) + checkDirection(y, x, 1, 1); 
    if (count == _required_to_win - 1) {
      _end = true;
      return;
    }
    
    //diagonally 2
    count = checkDirection(y, x, -1, 1) + checkDirection(y, x, 1, -1); 
    if (count == _required_to_win - 1) {
      _end = true;
      return;
    }
  }
  
  int checkDirection(int y, int x, int dy, int dx) {
    int count = 0;
    int i = y + dy;
    int j = x + dx;
    if ((i == -1) || (j == -1) || (i == _plocha.length) || (j == _plocha[y].length)) {
      return count;
    }
    while (_plocha[i][j] == _player) {
      count++;
      i += dy;
      j += dx;
      if ((i == -1) || (j == -1) || (i == _plocha.length) || (j == _plocha[y].length)) {
        return count;
      }
    }
    return count;
  }
  
  CanvasElement generateElement() {
    CanvasElement canvas = new CanvasElement();
    canvas.width = 500;
    canvas.height = 500;
    
    _context = canvas.getContext('2d');
    
    _x = (canvas.width / _width).round();
    _y = (canvas.height / _height).round();
    for (int i = 0; i < _plocha.length; i++) {
      for (int j = 0; j < _plocha[i].length; j++) {
        //context.fillText(this.plocha[i][j].toString(), x*j, y*i);
        //context.fillText((x*j).toString() + " " + (y*i).toString(), x*j, y*i);
        _context.strokeRect(_x*j, _y*i, _x, _y);
      }
    }
    
    return _context.canvas;
  }
  
  void draw() {
    _x = (_context.canvas.width / _width).round();
    _y = (_context.canvas.height / _height).round();
    
    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
    for (int i = 0; i < _plocha.length; i++) {
        for (int j = 0; j < _plocha[i].length; j++) {
          _context.strokeRect(_x*j, _y*i, _x, _y);
          if (_plocha[i][j] == 1) {
            _context.beginPath();
            _context.arc(_x*j + _x/2, _y*i + _y/2, _x / 3, 0, math.PI*2);
            _context.closePath();
            _context.fill();
          } if (_plocha[i][j] == 2) {
            _context.beginPath();
            _context.moveTo(_x*j + _x/5, _y*i + _y/5);
            _context.lineTo(_x*(j+1) - _x/5, _y*(i+1) - _y/5);
            _context.moveTo(_x*(j+1) - _x/5, _y*i + _y/5);
            _context.lineTo(_x*j + _x/5, _y*(i+1) - _y/5);
            _context.closePath();
            _context.stroke();
          }
        }
      }
  }
}

void main() { 
  Piskvorky p = new Piskvorky("#container", 10, 10);
}
