var ChosenImage = React.createClass({
  render: function(){
    return (<img onClick={this.props.click_handler} className='pure-img center grey-border hover-yellow-border' width='90%' src={'/uploads/' + this.props.file_hash + '/original'}></img>)
  }
});
