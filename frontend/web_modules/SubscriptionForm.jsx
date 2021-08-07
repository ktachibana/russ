import React, {useState} from 'react';
import api from 'Api';

export default function SubscriptionForm({subscription, existingTags, onSave, onClose}) {
  const isNewRecord = !subscription.id;

  const [title, setTitle] = useState(isNewRecord ? '' : subscription.title);
  const [tags, setTags] = useState(isNewRecord ? '' : subscription.tags.map(tag => tag.name).join(', '));
  const [hideDefault, setHideDefault] = useState(isNewRecord ? false : subscription.hideDefault);

  const addTag = tag => {
    const currentTags = tags.split(',').map(s => s.trim()).filter(s => s);
    setTags([...currentTags, tag.name].join(', '));
  }

  const submit = e => {
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
      <div className='form-group'>
        <label htmlFor="subscription_title">Title</label>
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
      <div className='form-group'>
        <div>
          <label htmlFor="subscription_tag_list">Tags</label>
          <input
            className="form-control"
            type="text"
            value={tags}
            onChange={e => { setTags(e.target.value); }}
            name="subscription[tag_list]"
            id="subscription_tag_list"
          />
          <div className='owned-tags'>
            {existingTags.map(tag =>
              <button key={tag.id} className='btn btn-default btn-xs' type='button' onClick={() => { addTag(tag); }}>
                {tag.name} ({tag.count})
              </button>
            )}
          </div>
        </div>
      </div>
      <div className="form-group">
        <label>
          <input type="checkbox" checked={hideDefault} onChange={e => { setHideDefault(e.target.checked); }} />
          トップページに表示しない
        </label>
      </div>
      <div className='form-group pull-right'>
        <button className='btn btn-primary' type='submit'>
          <span className='glyphicon glyphicon-ok'/>
          {isNewRecord ? '登録' : '更新'}する
        </button>
        {!isNewRecord ?
          <button className='btn btn-default' type='button' onClick={onClose}>
            <span className='glyphicon glyphicon-remove'/>
            閉じる
          </button> :
          null
        }
      </div>
      <div className='clearfix'/>
    </form>
  );
}
