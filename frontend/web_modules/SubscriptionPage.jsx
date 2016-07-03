import React from 'react';
import { withRouter } from 'react-router';
import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import ItemPanel from 'ItemPanel';
import SubscriptionPanel from 'SubscriptionPanel';
import Pagination from 'Pagination';

class SubscriptionPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      subscription: null,
      items: [],
      page: 1,
      pagination: null
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
    const url = ApiRoutes.itemsPath({subscription_id: this.state.subscription.id, page: page});
    $.getJSON(url).then((data) => {
      this.setState({
        items: data.items,
        page: page,
        pagination: data.pagination
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
      this.loadSubscription(props.params.id).then((subscription) => {
        this.setState({
          subscription: subscription,
          items: subscription.feed.items,
          page: 1,
          pagination: subscription.pagination
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
            pagination: null
          });
        }
      }, (xhr) => {
        if(xhr.responseJSON.type == 'feedNotFound') {
          this.props.router.push('/items/');
        }
      });
    }
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
        <SubscriptionPanel subscription={this.state.subscription} tags={this.props.tags}/>

        {this.state.pagination ?
          <Pagination pagination={this.state.pagination}
                      currentPage={this.state.page}
                      onPageChange={this.pagenationChanged.bind(this)}/>
          : null
        }

        <div className='items'>
          {this.state.items.map(item =>
            <ItemPanel key={item.id || item.link} item={item} hideFeed={true}/>
          )}
        </div>

        {this.state.pagination ?
          <Pagination pagination={this.state.pagination}
                      currentPage={this.state.page}
                      onPageChange={this.pagenationChanged.bind(this)}/>
          : null
        }
      </div>
    );
  }
}

export default withRouter(SubscriptionPage);
