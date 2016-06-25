import React from 'react';
import { withRouter } from 'react-router';
import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import ItemPanel from 'ItemPanel';
import SubscriptionPanel from 'SubscriptionPanel';

class SubscriptionPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      subscription: null,
      items: [],
      page: 1,
      lastPage: true
    };
  }

  loadSubscription(id) {
    return new Promise((resolve, reject) => {
      const url = ApiRoutes.subscriptionPath(id);
      $.getJSON(url).then((subscription) => {
          resolve(subscription);
        },
        reject);
    });
  }

  updateItems({page = this.state.page}) {
    return new Promise((resolve, reject) => {
      const url = ApiRoutes.itemsPath({subscription_id: this.state.subscription.id, page: page});
      $.getJSON(url).then((data) => {
        resolve({
          loadedItems: data.items,
          setNextItems: (nextItems) => {
            this.setState({
              items: nextItems,
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
    return this.updateItems({page: this.state.page + 1}).then(({loadedItems, setNextItems}) => {
      setNextItems(this.state.items.concat(loadedItems));
    });
  }

  get isNewRecord() {
    return !this.state.subscription.id
  }

  get isEditing() {
    return this.isNewRecord || this.state.isEdit;
  }

  componentDidMount() {
    this.pageChanged(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params != this.props.params) {
      this.pageChanged(nextProps);
    }
  }

  pageChanged(props) {
    if (props.params.id) {
      this.loadSubscription(props.params.id).then((subscription) => {
        this.setState({
          subscription: subscription,
          items: subscription.feed.items,
          page: 1,
          lastPage: subscription.lastPage
        });
      });
    } else {
      const url = props.params.url;
      $.getJSON(ApiRoutes.newSubscriptionPath(), {
        url: url
      }).then((feed) => {
        if (feed.id) {
          this.props.router.push(`/subscriptions/${feed.id}`);
        } else {
          this.setState({
            subscription: {feed: feed},
            items: feed.items,
            lastPage: true
          });
        }
      }, (xhr) => {
        if(xhr.responseJSON.type == 'feedNotFound') {
          this.props.router.push('/items/');
        }
      });
    }
  }

  render() {
    if (!this.state.subscription) {
      return null;
    }

    return (
      <div>
        <SubscriptionPanel subscription={this.state.subscription} tags={this.props.tags}/>

        <div className='items'>
          {this.state.items.map(item =>
            <ItemPanel key={item.id || item.link} item={item} hideFeed={true}/>
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

export default withRouter(SubscriptionPage);
