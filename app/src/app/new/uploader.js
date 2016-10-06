var Uploader = React.createClass({
  getInitialState: function() {
    return {
      uploading: false,
    };
  },

  submit: function(e){
    var form_data = new FormData();
    this.setState({uploading: true});
    form_data.append('file', e.target.files[0]);

    $.post({
      url: '/uploads',
      type: 'POST',
      data: form_data, 
      contentType: false,
      processData: false,
      success: function(response){
        this.setState({uploading: false});
        this.props.add_upload(JSON.parse(response));
      }.bind(this)
    });
  },
  render: function(){
    var disabled = '';
    var pure_disabled = '';
    var camera = 'fa-camera';
    var upload = 'fa-upload';
    if (this.state.uploading) {
      disabled = 'disabled';
      pure_disabled = 'pure-button-disabled';
      camera = 'fa-gear fa-spin';
      upload = 'fa-gear fa-spin';
    }

    return (
      <div className='purt-g .js-submit-css'>
        <div className='pure-u-1-6'></div>
        <div className='pure-u-1-6'>
          <h3 className='file-upload'>
            <label className={'center pure-button ' + pure_disabled}>
              <span>
                <i className={'fa fa-2x ' + camera}></i>
              </span>
              <input type='file' onChange={this.submit} className='upload'></input>
            </label>
          </h3>
        </div>
        <div className='pure-u-1-6'></div>
        <div className='pure-u-1-6'></div>
        <div className='pure-u-1-6'>
          <h3 className='file-upload'>
            <label className={'center pure-button ' + pure_disabled}>
              <span>
                <i className={'fa fa-2x ' + upload}></i>
              </span>
              <input type='file' onChange={this.submit} className='upload'></input>
            </label>
          </h3>
        </div>
        <div className='pure-u-1-6'></div>
      </div>
    )
  }
});
