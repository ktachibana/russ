import React from 'react';
import $ from 'jquery';
import Routes from './app/routes';

export default class SubscriptionForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      title: props.subscription.title,
      tags: props.subscription.tags.map(tag => tag.name).join(', ')
    };
  }

  addTag(tag) {
    this.setState({tags: [...this.currentTags, tag.name].join(', ')})
  }

  tagsChanged(e) {
    this.setState({tags: e.target.value});
  }

  titleChanged(e) {
    this.setState({title: e.target.value});
  }

  submit(e) {
    e.preventDefault();

    const subscriptionData = {
      title: this.state.title,
      tag_list: this.state.tags
    };
    if (!this.props.subscription.id) {
      Object.assign(subscriptionData, {
        feed_attributes: {
          url: this.props.subscription.feed.url
        }
      });
    }

    $.ajax(this.url, {
      type: this.method,
      dataType: 'json',
      data: {
        subscription: subscriptionData
      }
    }).then((data) => {
      this.props.onClose();
      location.href = `#/subscriptions/${data.id}`;
    });
  }

  get currentTags() {
    return this.state.tags.split(',').map(s => s.trim()).filter(s => s);
  }

  get isNewRecord() {
    return !this.props.subscription.id;
  }

  get url() {
    return this.isNewRecord ? Routes.subscriptionsPath() : Routes.subscriptionPath(this.props.subscription.id);
  }

  get method() {
    return this.isNewRecord ? 'post' : 'put';
  }

  get submitText() {
    return this.isNewRecord ? '登録' : '更新';
  }

  render() {
    return (
      <form onSubmit={this.submit.bind(this)}>
        {!this.props.subscription.id ?
          <input defaultValue={this.props.subscription.feed.url} type="hidden" name="subscription[feed_attributes][url]"/> :
          null
        }
        <div className='form-group'>
          <label for="subscription_title">Title</label>
          <input className="form-control" placeholder={this.props.subscription.feed.title} value={this.state.title} onChange={this.titleChanged.bind(this)} type="text" name="subscription[title]" id="subscription_title"/>
        </div>
        <div className='form-group'>
          <div>
            <label for="subscription_tag_list">Tags</label>
            <input className="form-control" type="text" value={this.state.tags} onChange={this.tagsChanged.bind(this)} name="subscription[tag_list]" id="subscription_tag_list"/>
            <div className='owned-tags'>
              {this.props.tags.map(tag =>
                <button key={tag.id} className='btn btn-default btn-xs' type='button' onClick={() => { this.addTag(tag) }}>
                  {tag.name} ({tag.count})
                </button>
              )}
            </div>
          </div>
        </div>
        <div className='form-group pull-right'>
          <button className='btn btn-primary' type='submit'>
            <span className='glyphicon glyphicon-ok'/>
            {this.submitText}する
          </button>
          {!this.isNewRecord ?
            <button className='btn btn-default' type='button' onClick={this.props.onClose}>
              <span className='glyphicon glyphicon-remove'/>
              閉じる
            </button> :
            null
          }
        </div>
        <div className='clearfix'></div>
      </form>
    );
  }
}
