var Mimics = React.createClass({
  getInitialState: function() {
    return {
      mimics: []
    };
  },

  componentDidMount: function() {
    this.serverRequest = $.get('/mimics', function (result) {
      var result = JSON.parse(result);
      this.setState({
        mimics: result,
      });
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function(){
    var mimics = this.state.mimics.map(function(mimic) {
      var mimic_img = null;
      var key = mimic.content_hash + '-' + mimic.style_hash;
      if ( mimic.mimic_hash ) {
        mimic_img = ( <img className='pure-img center' src={'/files/' + mimic.mimic_hash}></img> );
      } else {
        mimic_img = ( <img className='pure-img center rotate' src='/images/logo-yellow.png'></img> );
      }
      return (
        <div key={key} className='pure-u-1-3 mimic'>
          <div className='pure-u-1'>
            { mimic_img }
          </div>
          <div className='pure-u-1-2 mimic-reveal margin-above'>
            <img className='pure-img center' src={'/files/' + mimic.content_hash}></img>
          </div>
          <div className='pure-u-1-2 mimic-reveal margin-above'>
            <img className='pure-img center' src={'/files/' + mimic.style_hash}></img>
          </div>
        </div>
      )
    });
    return (
      <div>
        <h1 className='center-text'>My Mimics</h1>
        <div className='pure-g mimics-index'>
          { mimics }
        </div>
      </div>
    )
  }
});
