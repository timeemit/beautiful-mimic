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
          <div className='pure-u-3-4'> 
            {/* Mimic Goes Here */}
          </div>
          <div className='pure-u-1-4 mimic-reveal'>
            <img className='pure-img' src={'/uploads/' + mimic.content_hash}></img>
            <img className='pure-img margin-above' src={'/uploads/' + mimic.style_hash}></img>
          </div>
        </div>
      )
    });
    return (
      <div className='pure-g mimics-index'>
        { mimics }
      </div>
    )
  }
});
