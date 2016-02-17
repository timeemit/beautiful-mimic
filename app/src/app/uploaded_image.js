var UploadedImage = React.createClass({
  choose_image: function() {
    this.props.choice_handler(this.props.upload);
  },
  render: function(){
    var className = 'center img-ctrl';
    if ( this.props.chosen.file_hash === this.props.upload.file_hash ) {
      className += ' active';
    }
    return (
      <div className='pure-u-1-2'>
        <div className={ className } >
          <img alt={ this.props.upload.filename } width='80%' onClick={ this.choose_image } className='pure-img center grey-border' src={ '/uploads/' + this.props.upload.file_hash }></img>
        </div>
      </div>
    );
  }
});
