import React from 'react';
import $ from 'jquery';
import Routes from './app/routes';
import TagButtons from 'tag-buttons';

class SubscriptionRow extends React.Component {
  get href() {
    return `#/subscriptions/${this.props.subscription.id}`;
  }

  render() {
    return (
      <ul className='list-group'>
        <li className='list-group-item'>
          <div className='list-group-item-heading'>
            <a href={this.href}>
              <b>{this.props.subscription.userTitle}</b>
            </a>

            {this.props.subscription.tags.map(tag =>
              <span key={tag.id} className='label label-default' style={{margin: '2px'}}>
                {tag.name}
              </span>
            )}
          </div>

          <div className='list-group-item-text'>
            <a href={this.href}>
              <i>{this.props.subscription.feed.latestItem.title}</i>
            </a>
          </div>
        </li>
      </ul>
    )
  }
}

export default class FeedsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      subscriptions: [],
      page: 1,
      isLastPage: true
    };
  }

  get currentTags() {
    return this.selectTags(this.props.params.tags);
  }

  selectTags(tagsParam) {
    const tagNames = (tagsParam || '').split(',');
    return this.props.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateFeeds({page = this.state.page, tagParam = this.props.params.tags}) {
    return new Promise((resolve, reject) => {
      const url = Routes.feedsPath({tag: tagParam ? tagParam.split(',') : [], page: page});
      $.getJSON(url).then((data) => {
          resolve({
            loadedSubscriptions: data.subscriptions,
            setNextSubscriptions: (nextSubscriptions) => {
              this.setState({
                subscriptions: nextSubscriptions,
                page: page,
                lastPage: data.lastPage
              });
            }
          });
        },
        reject);
    });
  }

  showMore() {
    return this.updateFeeds({page: this.state.page + 1}).then(({loadedSubscriptions, setNextSubscriptions}) => {
      setNextSubscriptions(this.state.subscriptions.concat(loadedSubscriptions));
    });
  }

  tagButtonsChanged(newTags) {
    const tagNames = newTags.map(tag => encodeURIComponent(tag.name));
    location.hash = `#/feeds/${tagNames.join(',')}`;
  }

  componentDidMount() {
    this.updateFeeds({}).then(({loadedSubscriptions, setNextSubscriptions}) => {
      setNextSubscriptions(loadedSubscriptions);
    });
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.tags != this.props.params.tags) {
      this.updateFeeds({tagParam: nextProps.params.tags || null}).then(({loadedSubscriptions, setNextSubscriptions}) => {
        setNextSubscriptions(loadedSubscriptions);
      });
    }
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.props.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
        <hr/>

        <div className='container-fluid'>
          {this.state.subscriptions.map(subscription =>
            <div key={subscription.id}>
              <SubscriptionRow subscription={subscription}/>
            </div>
          )}
        </div>

        {!this.state.lastPage ?
          <div className='more text-center'>
            <button className='btn btn-primary' onClick={this.showMore.bind(this)}>続きを表示</button>
          </div> :
          null
        }
      </div>
    );
  }
}
