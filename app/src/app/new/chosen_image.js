var ChosenImage = React.createClass({
  render: function(){
    if ( ! this.props.file_hash ) {
      return null;
    }

    return (
      <ReactCSSTransitionGroup transitionName='chosen-image' transitionEnterTimeout={2000} transitionLeaveTimeout={1500} transitionAppearTimeout={2000} transitionAppear={true}>
        <div key={this.props.file_hash} onClick={this.props.click_handler} className='pure-g'>
          <div className='pure-u-4-5 center'>
            <div className='grey-border hover-yellow-border'>
              <img className='pure-u-1 pure-img' src={'/files/' + this.props.file_hash + '?style=original'}></img>
            </div>
          </div>
          <button className='pure-u-4-5 pure-button center'><i className='fa fa-edit'></i></button>
        </div>
      </ReactCSSTransitionGroup>
    )
  }
});
