var ChosenImage = React.createClass({
  displayName: 'ChosenImage',

  render: function () {
    if (!this.props.file_hash) {
      return null;
    }

    return React.createElement(
      ReactCSSTransitionGroup,
      { transitionName: 'chosen-image', transitionEnterTimeout: 2000, transitionLeaveTimeout: 1500, transitionAppearTimeout: 2000, transitionAppear: true },
      React.createElement('img', { key: this.props.file_hash, onClick: this.props.click_handler, className: 'pure-img center grey-border hover-yellow-border', width: '90%', src: '/uploads/' + this.props.file_hash + '?style=original' })
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
        { className: 'drawer green-background center' },
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
          { className: 'pure-u-1 pure-u-lg-1-2' },
          ' ',
          tip,
          ' '
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1 pure-u-lg-1-2' },
          ' '
        )
      );
    } else {
      return React.createElement(
        'div',
        { className: 'pure-g' },
        React.createElement(
          'div',
          { className: 'pure-u-1 pure-u-lg-1-2' },
          ' '
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1 pure-u-lg-1-2' },
          ' ',
          tip,
          ' '
        )
      );
    }
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
      var key = mimic.content_hash + '-' + mimic.style_hash;
      return React.createElement(
        'div',
        { key: key, className: 'pure-u-1-3 mimic' },
        React.createElement(
          'div',
          { className: 'pure-u-1' },
          React.createElement('img', { className: 'pure-img center', src: '/uploads/' + '32a9dc2a78d2c4fa02dfbd914c7270374f77a11a9e2b2c3d8341c65ddfdb7113' })
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2 mimic-reveal margin-above' },
          React.createElement('img', { className: 'pure-img center', src: '/uploads/' + mimic.content_hash })
        ),
        React.createElement(
          'div',
          { className: 'pure-u-1-2 mimic-reveal margin-above' },
          React.createElement('img', { className: 'pure-img center', src: '/uploads/' + mimic.style_hash })
        )
      );
    });
    return React.createElement(
      'div',
      null,
      React.createElement(
        'h1',
        { className: 'center-text' },
        'My Mimics'
      ),
      React.createElement(
        'div',
        { className: 'pure-g mimics-index' },
        mimics
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
    var callback = function (response) {
      window.location = '/';
    };
    $.post('/mimics', data, callback);
  },

  render: function () {
    var reveal_drawer = this.state.reveal_content || this.state.reveal_style;
    var chosen = null;
    var choice_handler = null;

    if (reveal_drawer) {
      if (this.state.reveal_content) {
        chosen = this.state.content_choice;
        choice_handler = this.choose_content;
      } else {
        chosen = this.state.style_choice;
        choice_handler = this.choose_style;
      }
    }
    return React.createElement(
      'div',
      { className: 'pure-g' },
      React.createElement(
        'div',
        { className: 'pure-u-1-2' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Photo'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_content, file_hash: this.state.content_choice.file_hash })
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1-2' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Style'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_style, file_hash: this.state.style_choice.file_hash })
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
        { onClick: this.submit, className: 'pure-button pure-button-primary pure-u-1 page-break' },
        React.createElement(
          'h2',
          { className: 'center-text' },
          'Make a Mimic'
        )
      )
    );
  }
});
var UploadedImage = React.createClass({
  displayName: 'UploadedImage',

  choose_image: function () {
    this.props.choice_handler(this.props.upload);
  },
  render: function () {
    var className = 'center img-ctrl';
    if (this.props.chosen.file_hash === this.props.upload.file_hash) {
      className += ' active';
    }
    return React.createElement(
      'div',
      { className: 'pure-u-1-6' },
      React.createElement(
        'div',
        { className: className },
        React.createElement('img', { alt: this.props.upload.filename, onClick: this.choose_image, className: 'pure-img center grey-border', src: '/uploads/' + this.props.upload.file_hash })
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
          React.createElement(
            'i',
            { className: 'fa fa-upload' },
            ' Upload'
          )
        ),
        React.createElement('input', { type: 'file', onChange: this.submit, className: 'upload' })
      )
    );
  }
});
