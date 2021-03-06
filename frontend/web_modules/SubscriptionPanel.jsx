import React from 'react';
import { withRouter } from 'react-router-dom';
import SubscriptionForm from 'SubscriptionForm';
import api from 'Api';

class SubscriptionPanel extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      isEdit: false
    };
  }

  get isNewRecord() {
    return !this.props.subscription.id
  }

  get isEditing() {
    return this.isNewRecord || this.state.isEdit;
  }

  unsubscribeClicked(e) {
    e.preventDefault();
    if (!confirm('登録解除してよろしいですか？')) {
      return;
    }

    api.unsubscribeFeed(this.props.subscription.id).then(() => {
      this.props.history.push('/feeds/1/');
    });
  }

  edit() {
    this.setState({isEdit: true});
  }

  closeForm() {
    this.setState({isEdit: false});
  }

  saved(id) {
    this.closeForm();
    this.props.onSave(id);
  }

  formCloseClicked() {
    this.closeForm();
  }

  render() {
    const subscription = this.props.subscription;

    return (
      <div className='well'>
        <div className='feed'>
          {!this.isNewRecord ? (
            <div className='pull-right'>
              <a className='btn btn-danger' onClick={this.unsubscribeClicked.bind(this)}>
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

        {this.isEditing ? (
          <div className='edit-subscription'>
            <SubscriptionForm subscription={subscription}
                              tags={this.props.tags}
                              onSave={this.saved.bind(this)}
                              onClose={this.formCloseClicked.bind(this)}/>
          </div>
        ) : (
          <div className='show-subscription'>
            {subscription.tags.map(tag =>
              <span key={tag.id} className='label label-default' style={{margin: '2px'}}>
                {tag.name}
              </span>
            )}
            <button className='btn btn-default pull-right' onClick={this.edit.bind(this)}>
              <span className='glyphicon glyphicon-edit'/>編集
            </button>
            <div className='clearfix'/>
          </div>
        )}
      </div>
    );
  }
}

export default withRouter(SubscriptionPanel);
