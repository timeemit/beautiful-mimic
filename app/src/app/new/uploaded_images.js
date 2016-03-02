var UploadedImages = React.createClass({
  render: function(){
    var chosen = this.props.chosen;
    var choice_handler = this.props.choice_handler;
    var imgs = this.props.uploads.map(function(upload) {
      return ( <UploadedImage key={upload.file_hash} choice_handler={choice_handler} upload={upload} chosen={chosen} /> )
    });
    return (
      <div className='pure-g'>
      { imgs }
      </div>
    );
  }
});
