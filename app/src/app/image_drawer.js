var ImageDrawer = React.createClass({
  render: function(){
    if ( !this.props.reveal ) {
      return null;
    }
    return (
      <div>
        <div className='center pointer-up'>
          <div className='green-background pointer-up-left'></div>
          <div className='green-background pointer-up-right'></div>
        </div>
        <div className='drawer green-background center'>
          <UploadedImages choice_handler={this.props.choice_handler} chosen={this.props.chosen} uploads={this.props.uploads} />
          <Uploader />
        </div>
      </div>
    );
  }

});
