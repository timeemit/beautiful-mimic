var ChosenImage = React.createClass({
  render: function(){
    if ( ! this.props.file_hash ) {
      return null;
    }

    return (
      <ReactCSSTransitionGroup transitionName='chosen-image' transitionEnterTimeout={2000} transitionLeaveTimeout={1500} transitionAppearTimeout={2000} transitionAppear={true}>
        <img key={this.props.file_hash} onClick={this.props.click_handler} className='pure-img center grey-border hover-yellow-border' width='90%' src={'/uploads/' + this.props.file_hash + '?style=original'}></img>
      </ReactCSSTransitionGroup>
    )
  }
});
