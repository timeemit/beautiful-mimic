var Uploader = React.createClass({
  submit: function(e){
    var form_data = new FormData();

    form_data.append('file', e.target.files[0]);

    $.post({
      url: '/uploads',
      type: 'POST',
      data: form_data, 
      contentType: false,
      processData: false,
      success: function(response){
        this.props.add_upload(JSON.parse(response));
      }.bind(this)
    });
  },
  render: function(){
    return (
      <h3>
        <label className='file-upload center pure-button'>
          <span>
            <i className='fa fa-2x fa-upload'></i>
          </span>
          <input type='file' onChange={this.submit} className='upload'></input>
        </label>
      </h3>
    )
  }
});
