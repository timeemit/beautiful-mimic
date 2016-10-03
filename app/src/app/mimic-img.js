var MimicImg = React.createClass({
  render: function() {
    var mimic = this.props.mimic;

    if ( mimic.mimic_hash ) {
      return ( <img className='pure-img center' src={'/files/' + mimic.mimic_hash + '?style=original'}></img> );
    } else {
      return ( <img className='pure-img center rotate' src='/images/logo-yellow.png'></img> );
    }
  }
});
