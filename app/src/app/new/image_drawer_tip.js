var ImageDrawerTip = React.createClass({
  render: function(){
    tip = (
      <div className='center pointer-up'>
        <div className='green-background pointer-up-left'></div>
        <div className='green-background pointer-up-right'></div>
      </div>
    );
    if ( this.props.left ) {
      return ( 
        <div className='pure-g'>
          <div className="pure-u-1 pure-u-lg-1-2"> { tip } </div>
          <div className="pure-u-1 pure-u-lg-1-2"> </div>
        </div>
      )
    } else {
      return (
        <div className='pure-g'>
          <div className="pure-u-1 pure-u-lg-1-2"> </div>
          <div className="pure-u-1 pure-u-lg-1-2"> {tip} </div>
        </div>
      )
    }
  }
});
