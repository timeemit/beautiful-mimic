var ChosenImage = React.createClass({
  render: function(){
    if ( ! this.props.file_hash ) {
      return null;
    }

    return (
      <ReactCSSTransitionGroup transitionName='chosen-image' transitionEnterTimeout={2000} transitionLeaveTimeout={1500} transitionAppearTimeout={2000} transitionAppear={true}>
        <div key={this.props.file_hash} onClick={this.props.click_handler} className='pure-g chosen-image'>
          <div className='pure-u-4-5 center'>
            <div className='pure-g display'>
              <div className='container center'>
                <img className='center grey-border hover-yellow-border' src={'/files/' + this.props.file_hash + '?style=original'}></img>
                <button className='pure-button rounded-bottom'><i className='fa fa-2x fa-hand-pointer-o'></i></button>
              </div>
              
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>
    )
  }
});
