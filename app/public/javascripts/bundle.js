var rotateLeft = function (matrix) {
  var rows = matrix.length;
  var columns = matrix[0].length;
  var res = [];
  for (var row = 0; row < rows; ++row) {
    res.push([]);
    for (var column = 0; column < columns; ++column) {
      res[row][column] = matrix[column][columns - row - 1];
    }
  }
  return res;
};

var Tile = function (value, row, column) {
  this.value = value || 0;
  this.row = row || -1;
  this.column = column || -1;
  this.oldRow = -1;
  this.oldColumn = -1;
  this.markForDeletion = false;
  this.mergedInto = null;
  this.id = Tile.id++;
};

Tile.id = 0;

Tile.prototype.moveTo = function (row, column) {
  this.oldRow = this.row;
  this.oldColumn = this.column;
  this.row = row;
  this.column = column;
};

Tile.prototype.isNew = function () {
  return this.oldRow == -1 && !this.mergedInto;
};

Tile.prototype.hasMoved = function () {
  return this.fromRow() != -1 && (this.fromRow() != this.toRow() || this.fromColumn() != this.toColumn()) || this.mergedInto;
};

Tile.prototype.fromRow = function () {
  return this.mergedInto ? this.row : this.oldRow;
};

Tile.prototype.fromColumn = function () {
  return this.mergedInto ? this.column : this.oldColumn;
};

Tile.prototype.toRow = function () {
  return this.mergedInto ? this.mergedInto.row : this.row;
};

Tile.prototype.toColumn = function () {
  return this.mergedInto ? this.mergedInto.column : this.column;
};

var Board = function () {
  this.tiles = [];
  this.cells = [];
  for (var i = 0; i < Board.size; ++i) {
    this.cells[i] = [this.addTile(), this.addTile(), this.addTile(), this.addTile()];
  }
  this.addRandomTile();
  this.setPositions();
  this.won = false;
};

Board.prototype.addTile = function () {
  var res = new Tile();
  Tile.apply(res, arguments);
  this.tiles.push(res);
  return res;
};

Board.size = 4;

Board.prototype.moveLeft = function () {
  var hasChanged = false;
  for (var row = 0; row < Board.size; ++row) {
    var currentRow = this.cells[row].filter(function (tile) {
      return tile.value != 0;
    });
    var resultRow = [];
    for (var target = 0; target < Board.size; ++target) {
      var targetTile = currentRow.length ? currentRow.shift() : this.addTile();
      if (currentRow.length > 0 && currentRow[0].value == targetTile.value) {
        var tile1 = targetTile;
        targetTile = this.addTile(targetTile.value);
        tile1.mergedInto = targetTile;
        var tile2 = currentRow.shift();
        tile2.mergedInto = targetTile;
        targetTile.value += tile2.value;
      }
      resultRow[target] = targetTile;
      this.won |= targetTile.value == 2048;
      hasChanged |= targetTile.value != this.cells[row][target].value;
    }
    this.cells[row] = resultRow;
  }
  return hasChanged;
};

Board.prototype.setPositions = function () {
  this.cells.forEach(function (row, rowIndex) {
    row.forEach(function (tile, columnIndex) {
      tile.oldRow = tile.row;
      tile.oldColumn = tile.column;
      tile.row = rowIndex;
      tile.column = columnIndex;
      tile.markForDeletion = false;
    });
  });
};

Board.fourProbability = 0.1;

Board.prototype.addRandomTile = function () {
  var emptyCells = [];
  for (var r = 0; r < Board.size; ++r) {
    for (var c = 0; c < Board.size; ++c) {
      if (this.cells[r][c].value == 0) {
        emptyCells.push({ r: r, c: c });
      }
    }
  }
  var index = ~ ~(Math.random() * emptyCells.length);
  var cell = emptyCells[index];
  var newValue = Math.random() < Board.fourProbability ? 4 : 2;
  this.cells[cell.r][cell.c] = this.addTile(newValue);
};

Board.prototype.move = function (direction) {
  // 0 -> left, 1 -> up, 2 -> right, 3 -> down
  this.clearOldTiles();
  for (var i = 0; i < direction; ++i) {
    this.cells = rotateLeft(this.cells);
  }
  var hasChanged = this.moveLeft();
  for (var i = direction; i < 4; ++i) {
    this.cells = rotateLeft(this.cells);
  }
  if (hasChanged) {
    this.addRandomTile();
  }
  this.setPositions();
  return this;
};

Board.prototype.clearOldTiles = function () {
  this.tiles = this.tiles.filter(function (tile) {
    return tile.markForDeletion == false;
  });
  this.tiles.forEach(function (tile) {
    tile.markForDeletion = true;
  });
};

Board.prototype.hasWon = function () {
  return this.won;
};

Board.deltaX = [-1, 0, 1, 0];
Board.deltaY = [0, -1, 0, 1];

Board.prototype.hasLost = function () {
  var canMove = false;
  for (var row = 0; row < Board.size; ++row) {
    for (var column = 0; column < Board.size; ++column) {
      canMove |= this.cells[row][column].value == 0;
      for (var dir = 0; dir < 4; ++dir) {
        var newRow = row + Board.deltaX[dir];
        var newColumn = column + Board.deltaY[dir];
        if (newRow < 0 || newRow >= Board.size || newColumn < 0 || newColumn >= Board.size) {
          continue;
        }
        canMove |= this.cells[row][column].value == this.cells[newRow][newColumn].value;
      }
    }
  }
  return !canMove;
};

var BoardView = React.createClass({
  displayName: 'BoardView',

  getInitialState: function () {
    return { board: new Board() };
  },
  restartGame: function () {
    this.setState(this.getInitialState());
  },
  handleKeyDown: function (event) {
    if (this.state.board.hasWon()) {
      return;
    }
    if (event.keyCode >= 37 && event.keyCode <= 40) {
      event.preventDefault();
      var direction = event.keyCode - 37;
      this.setState({ board: this.state.board.move(direction) });
    }
  },
  handleTouchStart: function (event) {
    if (this.state.board.hasWon()) {
      return;
    }
    if (event.touches.length != 1) {
      return;
    }
    this.startX = event.touches[0].screenX;
    this.startY = event.touches[0].screenY;
    event.preventDefault();
  },
  handleTouchEnd: function (event) {
    if (this.state.board.hasWon()) {
      return;
    }
    if (event.changedTouches.length != 1) {
      return;
    }
    var deltaX = event.changedTouches[0].screenX - this.startX;
    var deltaY = event.changedTouches[0].screenY - this.startY;
    var direction = -1;
    if (Math.abs(deltaX) > 3 * Math.abs(deltaY) && Math.abs(deltaX) > 30) {
      direction = deltaX > 0 ? 2 : 0;
    } else if (Math.abs(deltaY) > 3 * Math.abs(deltaX) && Math.abs(deltaY) > 30) {
      direction = deltaY > 0 ? 3 : 1;
    }
    if (direction != -1) {
      this.setState({ board: this.state.board.move(direction) });
    }
  },
  componentDidMount: function () {
    window.addEventListener('keydown', this.handleKeyDown);
  },
  componentWillUnmount: function () {
    window.removeEventListener('keydown', this.handleKeyDown);
  },
  render: function () {
    var cells = this.state.board.cells.map(function (row, index) {
      return React.createElement(
        'div',
        { key: index },
        row.map(function (_, column) {
          return React.createElement(Cell, { key: column });
        })
      );
    });
    var tiles = this.state.board.tiles.filter(function (tile) {
      return tile.value != 0;
    }).map(function (tile) {
      return React.createElement(TileView, { key: tile.id, tile: tile });
    });
    return React.createElement(
      'div',
      { className: 'board', onTouchStart: this.handleTouchStart, onTouchEnd: this.handleTouchEnd, tabIndex: '1' },
      cells,
      tiles,
      React.createElement(GameEndOverlay, { board: this.state.board, onRestart: this.restartGame })
    );
  }
});

var Cell = React.createClass({
  displayName: 'Cell',

  shouldComponentUpdate: function () {
    return false;
  },
  render: function () {
    return React.createElement(
      'span',
      { className: 'cell' },
      ''
    );
  }
});

var TileView = React.createClass({
  displayName: 'TileView',

  shouldComponentUpdate: function (nextProps) {
    if (this.props.tile != nextProps.tile) {
      return true;
    }
    if (!nextProps.tile.hasMoved() && !nextProps.tile.isNew()) {
      return false;
    }
    return true;
  },
  render: function () {
    var tile = this.props.tile;
    var classArray = ['tile'];
    classArray.push('tile' + this.props.tile.value);
    if (!tile.mergedInto) {
      classArray.push('position_' + tile.row + '_' + tile.column);
    }
    if (tile.mergedInto) {
      classArray.push('merged');
    }
    if (tile.isNew()) {
      classArray.push('new');
    }
    if (tile.hasMoved()) {
      classArray.push('row_from_' + tile.fromRow() + '_to_' + tile.toRow());
      classArray.push('column_from_' + tile.fromColumn() + '_to_' + tile.toColumn());
      classArray.push('isMoving');
    }
    var classes = classArray.join(' ');
    return React.createElement(
      'span',
      { className: classes, key: tile.id },
      tile.value
    );
  }
});

var GameEndOverlay = React.createClass({
  displayName: 'GameEndOverlay',

  render: function () {
    var board = this.props.board;
    var contents = '';
    if (board.hasWon()) {
      contents = 'Good Job!';
    } else if (board.hasLost()) {
      contents = 'Game Over';
    }
    if (!contents) {
      return null;
    }
    return React.createElement(
      'div',
      { className: 'overlay' },
      React.createElement(
        'p',
        { className: 'message' },
        contents
      ),
      React.createElement(
        'a',
        { className: 'link', href: window.location },
        'Whatever.',
        React.createElement('br', null),
        'View mimic!'
      ),
      React.createElement(
        'button',
        { className: 'tryAgain', onClick: this.props.onRestart, onTouchEnd: this.props.onRestart },
        'Not now! Try again.'
      )
    );
  }
});
var MimicShow = React.createClass({
  displayName: 'MimicShow',

  render: function () {
    var mimic = this.props.mimic;
    return React.createElement(
      'div',
      null,
      React.createElement(
        'div',
        { className: 'pure-u-1' },
        React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.mimic_hash + '?style=original' })
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1-2 margin-above' },
        React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.content_hash + '?style=original' })
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1-2 margin-above' },
        React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.style_hash + '?style=original' })
      )
    );
  }
});
var Mimics = React.createClass({
  displayName: 'Mimics',

  getInitialState: function () {
    return {
      mimics: []
    };
  },

  componentDidMount: function () {
    this.serverRequest = $.get('/mimics', function (result) {
      var result = JSON.parse(result);
      this.setState({
        mimics: result
      });
    }.bind(this));
  },

  componentWillUnmount: function () {
    this.serverRequest.abort();
  },

  render: function () {
    var mimics = this.state.mimics.map(function (mimic) {
      var mimic_img = null;
      var key = mimic.content_hash + '-' + mimic.style_hash;
      if (mimic.mimic_hash) {
        mimic_img = React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.mimic_hash });
      } else {
        mimic_img = React.createElement('img', { className: 'pure-img center rotate', src: '/images/logo-yellow.png' });
      }
      return React.createElement(
        'div',
        { key: key, className: 'pure-u-1-3 mimic' },
        React.createElement(
          'div',
          { className: 'pure-u-1' },
          mimic_img
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2 mimic-reveal margin-above' },
          React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.content_hash })
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2 mimic-reveal margin-above' },
          React.createElement('img', { className: 'pure-img center', src: '/files/' + mimic.style_hash })
        )
      );
    });
    return React.createElement(
      'div',
      null,
      React.createElement(
        'div',
        { className: 'pure-g mimics-index' },
        mimics
      )
    );
  }
});
var ChosenImage = React.createClass({
  displayName: 'ChosenImage',

  render: function () {
    if (!this.props.file_hash) {
      return null;
    }

    return React.createElement(
      ReactCSSTransitionGroup,
      { transitionName: 'chosen-image', transitionEnterTimeout: 2000, transitionLeaveTimeout: 1500, transitionAppearTimeout: 2000, transitionAppear: true },
      React.createElement(
        'div',
        { key: this.props.file_hash, onClick: this.props.click_handler, className: 'pure-g chosen-image' },
        React.createElement(
          'div',
          { className: 'pure-u-4-5 center' },
          React.createElement(
            'div',
            { className: 'pure-g display' },
            React.createElement(
              'div',
              { className: 'container center' },
              React.createElement('img', { className: 'center grey-border hover-yellow-border', src: '/files/' + this.props.file_hash + '?style=original' }),
              React.createElement(
                'button',
                { className: 'pure-button rounded-bottom' },
                React.createElement('i', { className: 'fa fa-2x fa-hand-pointer-o' })
              )
            )
          )
        )
      )
    );
  }
});
var NewMimic = React.createClass({
  displayName: 'NewMimic',

  getInitialState: function () {
    return {
      uploads: [],
      content_choice: {},
      style_choice: {},
      reveal_content: false,
      reveal_style: false
    };
  },

  componentDidMount: function () {
    this.serverRequest = $.get('/uploads', function (result) {
      var result = JSON.parse(result);
      this.setState({
        uploads: result,
        content_choice: result[0],
        style_choice: result[1],
        reveal_content: false,
        reveal_style: false
      });
    }.bind(this));
  },

  componentWillUnmount: function () {
    this.serverRequest.abort();
  },

  choose_content: function (choice) {
    this.setState({ content_choice: choice });
  },

  choose_style: function (choice) {
    this.setState({ style_choice: choice });
  },

  toggle_content: function () {
    this.setState({
      reveal_content: !this.state.reveal_content,
      reveal_style: false
    });
  },

  toggle_style: function () {
    this.setState({
      reveal_content: false,
      reveal_style: !this.state.reveal_style
    });
  },

  add_upload: function (upload) {
    var uploads = this.state.uploads;
    uploads.unshift(upload);
    this.setState({
      uploads: uploads
    });
  },

  submit: function () {
    var data = {
      content_hash: this.state.content_choice.file_hash,
      style_hash: this.state.style_choice.file_hash
    };
    var callback = function (new_mimic) {
      window.location = '/mimics/' + data.content_hash + '-' + data.style_hash;
    };
    $.post('/mimics', data, callback);
  },

  render: function () {
    var reveal_drawer = this.state.reveal_content || this.state.reveal_style;
    var chosen = null;
    var choice_handler = null;
    var content_choice = this.state.content_choice;
    var style_choice = this.state.style_choice;

    if (reveal_drawer) {
      if (this.state.reveal_content) {
        chosen = content_choice;
        choice_handler = this.choose_content;
      } else {
        chosen = style_choice;
        choice_handler = this.choose_style;
      }
    }
    return React.createElement(
      'div',
      { className: 'pure-g' },
      React.createElement(
        'div',
        { className: 'pure-u-1-2 image-select' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Photo'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_content, file_hash: content_choice.file_hash })
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1-2 image-select' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Style'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_style, file_hash: style_choice.file_hash })
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1' },
        React.createElement(
          ReactCSSTransitionGroup,
          { transitionName: 'image-drawer', transitionEnterTimeout: 500, transitionLeaveTimeout: 300 },
          React.createElement(ImageDrawer, { key: reveal_drawer, choice_handler: choice_handler, add_upload: this.add_upload, reveal: reveal_drawer, uploads: this.state.uploads, chosen: chosen, left: this.state.reveal_content })
        )
      ),
      React.createElement(
        'button',
        { onClick: this.submit, className: 'pure-button pure-u-1 page-break mimic-submit' },
        React.createElement(
          'h2',
          { className: 'center-text' },
          React.createElement(
            'i',
            { className: 'fa fa-2x' },
            '+'
          )
        )
      )
    );
  }
});
var ImageDrawer = React.createClass({
  displayName: 'ImageDrawer',

  render: function () {
    var pointer = null;

    if (!this.props.reveal) {
      return null;
    }
    return React.createElement(
      'div',
      null,
      React.createElement(ImageDrawerTip, { left: this.props.left }),
      React.createElement(
        'div',
        { className: 'drawer green-background dark-green-border center' },
        React.createElement(Uploader, { add_upload: this.props.add_upload }),
        React.createElement(UploadedImages, { choice_handler: this.props.choice_handler, chosen: this.props.chosen, uploads: this.props.uploads })
      )
    );
  }

});
var ImageDrawerTip = React.createClass({
  displayName: 'ImageDrawerTip',

  render: function () {
    tip = React.createElement(
      'div',
      { className: 'center pointer-up' },
      React.createElement('div', { className: 'green-background pointer-up-left' }),
      React.createElement('div', { className: 'green-background pointer-up-right' })
    );
    if (this.props.left) {
      return React.createElement(
        'div',
        { className: 'pure-g' },
        React.createElement(
          'div',
          { className: 'pure-u-1-2' },
          ' ',
          tip,
          ' '
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2' },
          ' '
        )
      );
    } else {
      return React.createElement(
        'div',
        { className: 'pure-g' },
        React.createElement(
          'div',
          { className: 'pure-u-1-2' },
          ' '
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2' },
          ' ',
          tip,
          ' '
        )
      );
    }
  }
});
var UploadedImage = React.createClass({
  displayName: 'UploadedImage',

  choose_image: function () {
    this.props.choice_handler(this.props.upload);
  },
  render: function () {
    var className = 'center img-ctrl';
    var upload = this.props.upload;
    if (this.props.chosen.file_hash === this.props.upload.file_hash) {
      className += ' active';
    }
    return React.createElement(
      'div',
      { className: 'pure-u-1-6' },
      React.createElement(
        'div',
        { className: className },
        React.createElement('img', { alt: upload.filename, onClick: this.choose_image, className: 'pure-img center grey-border', src: '/files/' + upload.file_hash })
      )
    );
  }
});
var UploadedImages = React.createClass({
  displayName: 'UploadedImages',

  render: function () {
    var chosen = this.props.chosen;
    var choice_handler = this.props.choice_handler;
    var imgs = this.props.uploads.map(function (upload) {
      return React.createElement(UploadedImage, { key: upload.file_hash, choice_handler: choice_handler, upload: upload, chosen: chosen });
    });
    return React.createElement(
      'div',
      { className: 'pure-g' },
      imgs
    );
  }
});
var Uploader = React.createClass({
  displayName: 'Uploader',

  submit: function (e) {
    var form_data = new FormData();

    form_data.append('file', e.target.files[0]);

    $.post({
      url: '/uploads',
      type: 'POST',
      data: form_data,
      contentType: false,
      processData: false,
      success: function (response) {
        this.props.add_upload(JSON.parse(response));
      }.bind(this)
    });
  },
  render: function () {
    return React.createElement(
      'h3',
      null,
      React.createElement(
        'label',
        { className: 'file-upload center pure-button' },
        React.createElement(
          'span',
          null,
          React.createElement('i', { className: 'fa fa-2x fa-upload' })
        ),
        React.createElement('input', { type: 'file', onChange: this.submit, className: 'upload' })
      )
    );
  }
});
