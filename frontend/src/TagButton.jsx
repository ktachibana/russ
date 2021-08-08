import React from 'react';
import classNames from 'classnames';

export default function TagButton({tag, active, onSelect, onToggle}) {
  function fireOnSelect() {
    onSelect(tag);
  }

  function fireOnToggle() {
    onToggle(tag);
  }

  return (
    <span className='btn-group btn-group-sm tag-button'>
      <a className={classNames('btn', `btn-${active ? 'info' : 'default'}`, {active: active})}
         onClick={() => fireOnSelect()}>
        <span className='glyphicon glyphicon-tag'/>
        {tag.name} ({tag.count})
      </a>
      <a className='btn btn-default' onClick={() => fireOnToggle()}>
        <span className={classNames('glyphicon', `glyphicon-${active ? 'minus' : 'plus'}`)}/>
      </a>
    </span>
  );
}
