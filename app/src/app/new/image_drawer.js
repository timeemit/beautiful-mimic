var ImageDrawer = React.createClass({
  render: function(){
    var pointer = null;

    if ( !this.props.reveal ) {
      return null;
    }
    return (
      <div>
        <ImageDrawerTip left={this.props.left} />
        <div className='drawer green-background center'>
          <Uploader add_upload={this.props.add_upload} />
          <UploadedImages choice_handler={this.props.choice_handler} chosen={this.props.chosen} uploads={this.props.uploads} />
        </div>
      </div>
    );
  }

});
