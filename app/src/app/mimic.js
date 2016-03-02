var MimicShow = React.createClass({
  render: function() {
    var mimic = this.props.mimic;
    var mimic_img = null;
    if ( mimic.mimic_hash ) {
      mimic_img = ( <img className='pure-img center' src={ '/files/' + mimic.mimic_hash + '?style=original' }></img> );
    } else {
      mimic_img = ( <img className='pure-img center rotate' src='/images/logo-yellow.png'></img> );
    }
    return (
      <div>
        <div className='pure-u-1'>
          { mimic_img }
        </div>
        <div className='pure-u-1-2 margin-above'>
          <img className='pure-img center' src={ '/files/' + mimic.content_hash + '?style=original' }></img>
        </div>
        <div className='pure-u-1-2 margin-above'>
          <img className='pure-img center' src={ '/files/' + mimic.style_hash + '?style=original' }></img>
        </div>
      </div>
    )
  }
});
