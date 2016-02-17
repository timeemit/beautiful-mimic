var ChosenImage = React.createClass({
  displayName: 'ChosenImage',

  render: function () {
    return React.createElement('img', { onClick: this.props.click_handler, className: 'pure-img center grey-border hover-yellow-border', width: '90%', src: '/uploads/' + this.props.file_hash + '/original' });
  }
});
var ImageDrawer = React.createClass({
  displayName: 'ImageDrawer',

  render: function () {
    if (!this.props.reveal) {
      return null;
    }
    return React.createElement(
      'div',
      null,
      React.createElement(
        'div',
        { className: 'center pointer-up' },
        React.createElement('div', { className: 'green-background pointer-up-left' }),
        React.createElement('div', { className: 'green-background pointer-up-right' })
      ),
      React.createElement(
        'div',
        { className: 'drawer green-background center' },
        React.createElement(UploadedImages, { choice_handler: this.props.choice_handler, chosen: this.props.chosen, uploads: this.props.uploads }),
        React.createElement(Uploader, null)
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

  render: function () {
    return React.createElement(
      'div',
      { className: 'pure-g' },
      React.createElement(
        'div',
        { className: 'pure-u-1 pure-u-lg-1-3' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Photo'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_content, file_hash: this.state.content_choice.file_hash }),
        React.createElement(
          ReactCSSTransitionGroup,
          { transitionName: 'image-drawer', transitionEnterTimeout: 500, transitionLeaveTimeout: 300 },
          React.createElement(ImageDrawer, { key: this.state.reveal_content, choice_handler: this.choose_content, reveal: this.state.reveal_content, uploads: this.state.uploads, chosen: this.state.content_choice })
        )
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1 pure-u-lg-1-3' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          '+'
        )
      ),
      React.createElement(
        'div',
        { className: 'pure-u-1 pure-u-lg-1-3' },
        React.createElement(
          'h1',
          { className: 'center-text' },
          'Style'
        ),
        React.createElement(ChosenImage, { click_handler: this.toggle_style, file_hash: this.state.style_choice.file_hash }),
        React.createElement(
          ReactCSSTransitionGroup,
          { transitionName: 'image-drawer', transitionEnterTimeout: 500, transitionLeaveTimeout: 300 },
          React.createElement(ImageDrawer, { key: this.state.reveal_style, choice_handler: this.choose_style, reveal: this.state.reveal_style, uploads: this.state.uploads, chosen: this.state.style_choice })
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
      { className: 'pure-u-1-2' },
      React.createElement(
        'div',
        { className: className },
        React.createElement('img', { alt: this.props.upload.filename, width: '80%', onClick: this.choose_image, className: 'pure-img center grey-border', src: '/uploads/' + this.props.upload.file_hash })
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

  render: function () {
    return React.createElement(
      'div',
      { className: 'pure-g' },
      React.createElement(
        'h3',
        { className: 'pure-u-1 center-text' },
        React.createElement(
          'a',
          { href: '#', className: 'pure-button pure-button-active' },
          React.createElement(
            'i',
            { className: 'fa fa-upload' },
            ' Upload'
          )
        )
      )
    );
  }
});
