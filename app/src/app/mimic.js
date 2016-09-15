var MimicShow = React.createClass({
  render: function() {
    var mimic_img = null;
    var mimic = this.props.mimic;

    var print_button = null;
    if ( mimic.mimic_hash ) { 
      print_button = (
        <a href={'/files/' + mimic.mimic_hash + '/print'} className='pure-u-1 pure-button pure-button-primary page-break'>
          <h2 className='center-text'><i className='fa fa-2x fa-print'></i></h2>
        </a>
      )
    }
    return (
      <div>
        <div className='pure-u-1'>
          <MimicImg mimic={mimic} />
        </div>
        <div className='pure-u-1-2 margin-above'>
          <img className='pure-img center' src={ '/files/' + mimic.content_hash + '?style=original' }></img>
        </div>
        <div className='pure-u-1-2 margin-above'>
          <img className='pure-img center' src={ '/files/' + mimic.style_hash + '?style=original' }></img>
        </div>
        { print_button }
      </div>
    );
  }
});
