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
      var key = mimic.content_hash + '-' + mimic.style_hash;
      return (
        <div key={key} className='pure-u-1-3 mimic'>
          <div className='pure-u-1'>
            <img className='pure-img center' src={'/uploads/' + '32a9dc2a78d2c4fa02dfbd914c7270374f77a11a9e2b2c3d8341c65ddfdb7113'}></img>
          </div>
          <div className='pure-u-1-2 mimic-reveal margin-above'>
            <img className='pure-img center' src={'/uploads/' + mimic.content_hash}></img>
          </div>
          <div className='pure-u-1-2 mimic-reveal margin-above'>
            <img className='pure-img center' src={'/uploads/' + mimic.style_hash}></img>
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
