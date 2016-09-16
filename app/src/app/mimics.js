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
      var key = mimic._id.$oid;
      return (
        <div key={key} className='pure-u-1-3 mimic page-break'>
          <a href={'/mimics/' + key}>
            <div className='pure-u-1'>
              <MimicImg mimic={mimic} />
            </div>
            <div className='pure-u-1-2 mimic-reveal margin-above'>
              <img className='pure-img center' src={'/files/' + mimic.content_hash}></img>
            </div>
            <div className='pure-u-1-2 mimic-reveal margin-above'>
              <img className='pure-img center' src={'/files/' + mimic.style_hash}></img>
            </div>
          </a>
        </div>
      )
    });
    return (
      <div>
        <div className='pure-g mimics-index'>
          <div className='pure-u-1 page-break-mini'>
            <a href='/mimics/new' className='pure-button center'>
              <h2 className='center-text'><i className='fa fa-2x'>+</i></h2>
            </a>
          </div>
          { mimics }
        </div>
      </div>
    );
  }
});
