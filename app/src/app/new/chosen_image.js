var ChosenImage = React.createClass({
  render: function(){
    if ( ! this.props.file_hash ) {
      return null;
    }

    return (
      <ReactCSSTransitionGroup transitionName='chosen-image' transitionEnterTimeout={2000} transitionLeaveTimeout={1500} transitionAppearTimeout={2000} transitionAppear={true}>
        <div key={this.props.file_hash} onClick={this.props.click_handler} className='pure-g'>
          <div className='pure-u-4-5 center'>
            <div className='pure-g display'>
              <div className='container center hover-yellow-border'>
                <img className='center grey-border' src={'/files/' + this.props.file_hash + '?style=original'}></img>
                <button className='pure-button grey-border rounded-bottom'><i className='fa fa-2x fa-hand-pointer-o'></i></button>
              </div>
              
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>
    )
  }
});
