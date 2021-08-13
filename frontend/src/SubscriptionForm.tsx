import React, {FormEvent, useState} from 'react';
import api from './Api';
import {Subscription, Tag} from "./types";

interface Props {
  subscription: Subscription
  existingTags: Tag[]
  onSave: (savedId: number) => void
  onClose: () => void
}

export default function SubscriptionForm({subscription, existingTags, onSave, onClose}: Props): JSX.Element {
  const isNewRecord = !subscription.id;

  const [title, setTitle] = useState(isNewRecord ? '' : subscription.title);
  const [tags, setTags] = useState(isNewRecord ? '' : subscription.tags.map(tag => tag.name).join(', '));
  const [hideDefault, setHideDefault] = useState(isNewRecord ? false : subscription.hideDefault);

  const addTag = (tag: Tag) => {
    const currentTags = tags.split(',').map(s => s.trim()).filter(s => s);
    setTags([...currentTags, tag.name].join(', '));
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const subscriptionData = {
      title: title,
      tag_list: tags,
      hide_default: (hideDefault ? 'true' : 'false')
    };
    if (isNewRecord) {
      Object.assign(subscriptionData, {
        feed_attributes: {
          url: subscription.feed.url
        }
      });
    }

    api.subscribeFeed(subscription.id, subscriptionData).then(({id}) => {
      onSave(id);
    });
  }

  return (
    <form onSubmit={submit}>
      <div className='my-2'>
        <label className="form-label" htmlFor="subscription_title">Title</label>
        <input
          className="form-control"
          placeholder={subscription.feed.title}
          value={title}
          onChange={e => { setTitle(e.target.value); }}
          type="text"
          name="subscription[title]"
          id="subscription_title"
        />
      </div>
      <div className='my-2'>
        <div>
          <label className="form-label" htmlFor="subscription_tag_list">Tags</label>
          <input
            className="form-control"
            type="text"
            value={tags}
            onChange={e => { setTags(e.target.value); }}
            name="subscription[tag_list]"
            id="subscription_tag_list"
          />
          <div className='owned-tags my-1'>
            {existingTags.map(tag =>
              <a key={tag.id} className='badge bg-secondary' type='button' onClick={() => { addTag(tag); }}>
                {tag.name} ({tag.count})
              </a>
            )}
          </div>
        </div>
      </div>
      <div className="my-2">
        <label>
          <input type="checkbox" checked={hideDefault} onChange={e => { setHideDefault(e.target.checked); }} />
          トップページに表示しない
        </label>
      </div>
      <div className='my-2 float-end'>
        <button className='btn btn-primary mx-2' type='submit'>
          ✓ {isNewRecord ? '登録' : '更新'}する
        </button>
        {!isNewRecord ?
          <button className='btn btn-secondary' type='button' onClick={onClose}>
            ✗ 閉じる
          </button> :
          null
        }
      </div>
      <div className='clearfix'/>
    </form>
  );
}
