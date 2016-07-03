import React from 'react';
import { withRouter } from 'react-router';
import ItemPanel from 'ItemPanel';
import SubscriptionPanel from 'SubscriptionPanel';
import WithPagination from 'WithPagination';
import api from 'Api';

class SubscriptionPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      page: 1,
      subscription: null,
      items: [],
      pagination: null
    };
  }

  updateItems({page = this.state.page}) {
    api.loadItems({page, subscriptionId: this.state.subscription.id}).then(({items, pagination}) => {
      this.setState({
        items: items,
        page: page,
        pagination: pagination
      });
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
      api.loadSubscription(props.params.id).then((subscription) => {
        this.setState({
          page: 1,
          subscription: subscription,
          items: subscription.feed.items,
          pagination: subscription.pagination
        });
      });
    } else {
      api.fetchFeed(props.params.url).then((feed) => {
        if (feed.id) {
          this.props.router.push(`/subscriptions/${feed.id}`);
        } else {
          this.setState({
            subscription: {feed: feed},
            items: feed.items,
            pagination: null
          });
        }
      }, (xhr) => {
        if(xhr.responseJSON.type == 'feedNotFound') {
          this.props.router.push('/items/1/');
        }
      });
    }
  }

  subscriptionSaved(id) {
    this.props.router.push(`/subscriptions/${id}`);
  }

  pagenationChanged(newPage) {
    this.updateItems({page: newPage});
  }

  render() {
    if (!this.state.subscription) {
      return null;
    }

    return (
      <div>
        <SubscriptionPanel subscription={this.state.subscription} tags={this.props.tags} onSave={this.subscriptionSaved.bind(this)}/>

        <WithPagination pagination={this.state.pagination}
                        currentPage={this.state.page}
                        onPageChange={this.pagenationChanged.bind(this)}>
          <div className='items'>
            {this.state.items.map(item =>
              <ItemPanel key={item.id || item.link} item={item} hideFeed={true}/>
            )}
          </div>
        </WithPagination>
      </div>
    );
  }
}

export default withRouter(SubscriptionPage);
