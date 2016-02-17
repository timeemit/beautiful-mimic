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
    return (
      <div className='pure-g'>
        <div className='pure-u-1 pure-u-lg-2-5'>
          <h1 className='center-text'>Photo</h1>
          <ChosenImage click_handler={this.toggle_content} file_hash={this.state.content_choice.file_hash} />
          <ReactCSSTransitionGroup transitionName='image-drawer' transitionEnterTimeout={500} transitionLeaveTimeout={300}>
            <ImageDrawer key={this.state.reveal_content} choice_handler={this.choose_content} reveal={this.state.reveal_content} uploads={this.state.uploads} chosen={this.state.content_choice} />
          </ReactCSSTransitionGroup>
        </div>
        <div className='pure-u-1 pure-u-lg-1-5'>
          <h1 className='center-text'>+</h1>
        </div>
        <div className='pure-u-1 pure-u-lg-2-5'>
          <h1 className='center-text'>Style</h1>
          <ChosenImage click_handler={this.toggle_style} file_hash={this.state.style_choice.file_hash} />
          <ReactCSSTransitionGroup transitionName='image-drawer' transitionEnterTimeout={500} transitionLeaveTimeout={300}>
            <ImageDrawer key={this.state.reveal_style}  choice_handler={this.choose_style} reveal={this.state.reveal_style} uploads={this.state.uploads} chosen={this.state.style_choice} />
          </ReactCSSTransitionGroup>
        </div>
      </div>
    );
  },
});
