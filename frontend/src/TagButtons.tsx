import React from 'react';
import _ from 'underscore';
import TagButton from './TagButton';
import {Tag} from "./types";

interface Props {
  tags: Tag[]
  currentTags: Tag[]
  onChange: (newTags: Tag[]) => void
}

export default function TagButtons({tags, currentTags, onChange}: Props) {
  function isActive(tag: Tag): boolean {
    return _.contains(currentTags, tag);
  }

  function tagSelected(tag: Tag): void {
    if (!_.isEqual(currentTags, [tag])) {
      onChange([tag]);
    }
  }

  function tagToggled(tag: Tag): void {
    onChange(toggleCurrentTag(tag));
  }

  function toggleCurrentTag(tag: Tag): Tag[] {
    if (isActive(tag)) {
      return _.without(currentTags, tag);
    } else {
      return [...currentTags, tag];
    }
  }

  return (
    <div>
      {tags.map(tag =>
        (
          <TagButton
            key={tag.id}
            tag={tag}
            active={isActive(tag)}
            onSelect={() => tagSelected(tag)}
            onToggle={() => tagToggled(tag)}/>
        )
      )}
    </div>
  );
}
