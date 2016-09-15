var ImageDrawer = React.createClass({
  render: function(){
    var pointer = null;
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
          <Uploader add_upload={this.props.add_upload} />
          <UploadedImages only_system={only_system} choice_handler={this.props.choice_handler} chosen={this.props.chosen} uploads={this.props.uploads} />
        </div>
      </div>
    );
  }

});
