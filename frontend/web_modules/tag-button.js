import React from 'react';
import classNames from 'classnames';

export default class TagButton extends React.Component {
  fireOnSelect() {
    this.props.onSelect(this.props.tag);
  }

  fireOnToggle() {
    this.props.onToggle(this.props.tag);
  }

  render() {
    return (
      <span className='btn-group btn-group-sm tag-button'>
        <a className={classNames('btn', `btn-${this.props.active ? 'info' : 'default'}`, {active: this.props.active})}
           onClick={this.fireOnSelect.bind(this)}>
          <span className='glyphicon glyphicon-tag'/>
          {this.props.tag.name} ({this.props.tag.count})
        </a>
        <a className='btn btn-default' onClick={this.fireOnToggle.bind(this)}>
          <span className={classNames('glyphicon', `glyphicon-${this.props.active ? 'minus' : 'plus'}`)}/>
        </a>
      </span>
    );
  }
}
