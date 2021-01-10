import React from 'react';
import api from 'Api';

export default class SubscriptionForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = props.subscription.id ? {
      title: props.subscription.title,
      tags: props.subscription.tags.map(tag => tag.name).join(', '),
      hideDefault: props.subscription.hideDefault
    } : {
      title: '',
      tags: '',
      hideDefault: false
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

  hideDefaultChanged(e) {
    this.setState({hideDefault: e.target.checked})
  }

  submit(e) {
    e.preventDefault();

    const subscriptionData = {
      title: this.state.title,
      tag_list: this.state.tags,
      hide_default: (this.state.hideDefault ? 'true' : 'false')
    };
    if (this.isNewRecord) {
      Object.assign(subscriptionData, {
        feed_attributes: {
          url: this.props.subscription.feed.url
        }
      });
    }

    api.subscribeFeed(this.props.subscription.id, subscriptionData).then((data) => {
      this.props.onSave(data.id);
    });
  }

  get currentTags() {
    return this.state.tags.split(',').map(s => s.trim()).filter(s => s);
  }

  get isNewRecord() {
    return !this.props.subscription.id;
  }

  get submitText() {
    return this.isNewRecord ? '登録' : '更新';
  }

  render() {
    return (
      <form onSubmit={this.submit.bind(this)}>
        <div className='form-group'>
          <label htmlFor="subscription_title">Title</label>
          <input className="form-control" placeholder={this.props.subscription.feed.title} value={this.state.title} onChange={this.titleChanged.bind(this)} type="text" name="subscription[title]" id="subscription_title"/>
        </div>
        <div className='form-group'>
          <div>
            <label htmlFor="subscription_tag_list">Tags</label>
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
        <div className="form-group">
          <label>
            <input type="checkbox" checked={this.state.hideDefault} onChange={this.hideDefaultChanged.bind(this)} />
            トップページに表示しない
          </label>
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
        <div className='clearfix'/>
      </form>
    );
  }
}
