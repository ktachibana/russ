import React from 'react';
import classNames from 'classnames';

export default class FlashMessage extends React.Component {
  render() {
    const nameToAlertType = {notice: 'success', alert: 'danger'};
    const alertType = nameToAlertType[this.props.name];

    // TODO: closable
    return (
      <div className={classNames("alert", "alert-dismissable", `alert-${alertType}`)}>
        <button className="close" area-hidden="true"/> &times;
        {' '}
        {this.props.children}
      </div>
    );
  }
}
