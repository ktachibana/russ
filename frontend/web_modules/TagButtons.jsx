import React from 'react';
import _ from 'underscore';
import TagButton from 'TagButton';

export default class TagButtons extends React.Component {
  isActive(tag) {
    return _.contains(this.props.currentTags, tag);
  }

  tagSelected(tag) {
    if (!_.isEqual(this.props.currentTags, [tag])) {
      this.props.onChange([tag]);
    }
  }

  tagToggled(tag) {
    this.props.onChange(this.toggleCurrentTag(tag));
  }

  toggleCurrentTag(tag) {
    if (this.isActive(tag)) {
      return _.without(this.props.currentTags, tag);
    } else {
      return [...this.props.currentTags, tag];
    }
  }

  render() {
    return (
      <div>
        {this.props.tags.map(tag =>
          (<TagButton key={tag.id}
                      tag={tag}
                      active={this.isActive(tag)}
                      onSelect={this.tagSelected.bind(this)}
                      onToggle={this.tagToggled.bind(this)}/>)
        )}
      </div>
    );
  }
}
