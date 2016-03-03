var MimicShow = React.createClass({
  render: function() {
    var mimic = this.props.mimic;
    return (
      <div>
        <div className='pure-u-1'>
          <img className='pure-img center' src={ '/files/' + mimic.mimic_hash + '?style=original' }></img>
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
