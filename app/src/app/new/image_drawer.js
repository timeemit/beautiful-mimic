var ImageDrawer = React.createClass({
  render: function(){
    var pointer = null;
    var uploader = null;
    var only_system = !this.props.left

    if ( !this.props.reveal ) {
      return null;
    }

    if ( !only_system ) {
      uploader = (
          <Uploader add_upload={this.props.add_upload} />
      );
    }

    return (
      <div>
        <ImageDrawerTip left={this.props.left} />
        <div className='drawer green-background dark-green-border center'>
          <ReactCSSTransitionGroup transitionName='floating-file' transitionEnterTimeout={1000} transitionLeaveTimeout={500} transitionAppearTimeout={1000} transitionAppear={true}>
            { uploader }
          </ReactCSSTransitionGroup>
          <UploadedImages only_system={only_system} choice_handler={this.props.choice_handler} chosen={this.props.chosen} uploads={this.props.uploads} />
        </div>
      </div>
    );
  }

});
