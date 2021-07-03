import React from 'react';
import _ from 'underscore';
import TagButton from 'TagButton';

export default function TagButtons({tags, currentTags, onChange}) {
  function isActive(tag) {
    return _.contains(currentTags, tag);
  }

  function tagSelected(tag) {
    if (!_.isEqual(currentTags, [tag])) {
      onChange([tag]);
    }
  }

  function tagToggled(tag) {
    onChange(toggleCurrentTag(tag));
  }

  function toggleCurrentTag(tag) {
    if (isActive(tag)) {
      return _.without(currentTags, tag);
    } else {
      return [...currentTags, tag];
    }
  }

  return (
    <div>
      {tags.map(tag =>
        (<TagButton key={tag.id}
                    tag={tag}
                    active={isActive(tag)}
                    onSelect={() => tagSelected(tag)}
                    onToggle={() => tagToggled(tag)}/>)
      )}
    </div>
  );
}
