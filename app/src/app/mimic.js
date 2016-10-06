var MimicShow = React.createClass({
  getInitialState: function() {
    return {
      mimic: this.props.mimic,
      request: null,
      interval: null
    };
  },

  componentDidMount: function() {
    setInterval(this.updateMimicRequest, 1000);
  },

  componentWillUnmount: function() {
    clearInterval(this.state.inteveral);
    this.state.request.abort();
  },

  updateMimicRequest: function() {
    request = $.get('/mimics/' + this.state.mimic._id.$oid + '.json', function (result) {
      var result = JSON.parse(result);
      this.setState({ mimic: result });
      if (this.state.mimic.mimic_hash) clearInterval(this.state.inteveral);
    }.bind(this));
    this.setState({ request: request });
  },

  render: function() {
    var mimic_img = null;
    var mimic = this.state.mimic;

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
        <div className='pure-u-2-5 page-break-mini'>
          <a href='/' className='pure-button center clickable rounded-corners'>
            <h2 className='center-text'><i className='fa fa-2x fa-angle-left'></i></h2>
          </a>
        </div>
        <div className='pure-u-1-5'></div>
        <div className='pure-u-2-5 page-break-mini'>
          <a href='/mimics/new' className='pure-button center clickable'>
            <h2 className='center-text'><i className='fa fa-2x'>+</i></h2>
          </a>
        </div>
        <div className='pure-u-1 page-break'>
          <MimicImg mimic={mimic} />
        </div>
        <div className='pure-u-1-2 page-break'>
          <img className='pure-img center' src={ '/files/' + mimic.content_hash + '?style=original' }></img>
        </div>
        <div className='pure-u-1-2 page-break'>
          <img className='pure-img center' src={ '/files/' + mimic.style_hash + '?style=original' }></img>
        </div>
        { print_button }
      </div>
    );
  }
});
