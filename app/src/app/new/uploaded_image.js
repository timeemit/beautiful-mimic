var UploadedImage = React.createClass({
  choose_image: function() {
    this.props.choice_handler(this.props.upload);
  },
  render: function(){
    var className = 'center img-ctrl';
    var upload = this.props.upload;
    if ( this.props.chosen.file_hash === this.props.upload.file_hash ) {
      className += ' active';
    }
    return (
      <div className='pure-u-1-6'>
        <div className={ className } >
          <img alt={ upload.filename } onClick={ this.choose_image } className='pure-img center grey-border' src={ '/files/' + upload.file_hash }></img>
        </div>
      </div>
    );
  }
});
