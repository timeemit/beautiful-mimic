var UploadedImages = React.createClass({
  render: function(){
    var chosen = this.props.chosen;
    var choice_handler = this.props.choice_handler;
    var uploads = this.props.uploads;
    if ( this.props.only_system ) {
      uploads = uploads.filter(function(upload) {
        return upload.user_hash == null;
      });
    }
    uploads = uploads.map(function(upload) {
      return ( <UploadedImage key={upload.file_hash} choice_handler={choice_handler} upload={upload} chosen={chosen} /> )
    });
    return (
      <div className='pure-g'>
      { uploads }
      </div>
    );
  }
});
