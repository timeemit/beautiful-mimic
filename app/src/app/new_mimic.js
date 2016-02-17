var NewMimic = React.createClass({
  getInitialState: function() {
    return {
      uploads: [],
      content_choice: {},
      style_choice: {},
      reveal_content: false,
      reveal_style: false
    };
  },

  componentDidMount: function() {
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

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  choose_content: function(choice) {
    this.setState({ content_choice: choice });
  },

  choose_style: function(choice) {
    this.setState({ style_choice: choice });
  },

  toggle_content: function() {
    this.setState({
      reveal_content: !this.state.reveal_content,
      reveal_style: false
    });
  },

  toggle_style: function() {
    this.setState({
      reveal_content: false,
      reveal_style: !this.state.reveal_style
    });
  },

  render: function() {
    var reveal_drawer = this.state.reveal_content || this.state.reveal_style;
    var chosen = null;
    var choice_handler = null;

    if ( reveal_drawer ) {
      if ( this.state.reveal_content ) {
        chosen = this.state.content_choice;
        choice_handler = this.choose_content;
      } else {
        chosen = this.state.style_choice;
        choice_handler = this.choose_style;
      }
    }
    return (
      <div className='pure-g'>
        <div className='pure-u-1-2'>
          <h1 className='center-text'>Photo</h1>
          <ChosenImage click_handler={this.toggle_content} file_hash={this.state.content_choice.file_hash} />
        </div>
        <div className='pure-u-1-2'>
          <h1 className='center-text'>Style</h1>
          <ChosenImage click_handler={this.toggle_style} file_hash={this.state.style_choice.file_hash} />
        </div>
        <div className='pure-u-1'>
          <ReactCSSTransitionGroup transitionName='image-drawer' transitionEnterTimeout={500} transitionLeaveTimeout={300}>
            <ImageDrawer key={reveal_drawer} left={this.state.reveal_content} choice_handler={choice_handler} reveal={reveal_drawer} uploads={this.state.uploads} chosen={chosen} />
          </ReactCSSTransitionGroup>
        </div>
        <div className='pure-u-1'>
          <div className='center-text'>
            <h2><button className='pure-button pure-button-primary'>Mimic</button></h2>
          </div>
        </div>
      </div>
    );
  },
});
