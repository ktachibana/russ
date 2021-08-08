import React, {useState, MouseEvent} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import SubscriptionForm from './SubscriptionForm';
import api from './Api';
import {Subscription, Tag} from "./types";

export default withRouter(SubscriptionPanel);

interface Props {
  subscription: Subscription
  tags: Tag[]
  onSave: (savedId: number) => void
}

function SubscriptionPanel({subscription, tags, onSave, history}: Props & RouteComponentProps) {
  const [isEdit, setIsEdit] = useState(false);

  const isNewRecord = !subscription.id;
  const isEditing = isNewRecord || isEdit;

  const unsubscribeClicked = (e: MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();

    if (!confirm('登録解除してよろしいですか？')) {
      return;
    }

    api.unsubscribeFeed(subscription.id).then(() => {
      history.push('/feeds/1/');
    });
  };

  const closeForm = () => {
    setIsEdit(false);
  };

  const saved = (id: number) => {
    closeForm();
    onSave(id);
  };

  const formCloseClicked = () => {
    closeForm();
  };

  return (
    <div className='well'>
      <div className='feed'>
        {!isNewRecord ? (
          <div className='pull-right'>
            <a className='btn btn-danger' onClick={unsubscribeClicked}>
              <span className='glyphicon glyphicon-trash'/>
              登録解除
            </a>
          </div>
        ) : null}
        <h1>
          <a target='_blank' href={subscription.feed.linkUrl}>
            {subscription.feed.title}
          </a>
          <a target='_blank' href={subscription.feed.url}>
            <span className='glyphicon glyphicon-file'/>
          </a>
        </h1>
        {/* TODO: dangerousなのなんとかする */}
        {subscription.feed.description ?
          <div className='description well' dangerouslySetInnerHTML={{__html: subscription.feed.description}}/> :
          null}
      </div>

      {isEditing ? (
        <div className='edit-subscription'>
          <SubscriptionForm
            subscription={subscription}
            existingTags={tags}
            onSave={saved}
            onClose={formCloseClicked}/>
        </div>
      ) : (
        <div className='show-subscription'>
          {subscription.tags.map(tag =>
            <span key={tag.id} className='label label-default' style={{margin: '2px'}}>
              {tag.name}
            </span>
          )}
          <button className='btn btn-default pull-right' onClick={() => { setIsEdit(true); }}>
            <span className='glyphicon glyphicon-edit'/>編集
          </button>
          <div className='clearfix'/>
        </div>
      )}
    </div>
  );
}
