import React from 'react';
import $ from 'jquery';
import Routes from './app/routes';
import ItemPanel from 'item-panel';

class RootPage extends React.Component {
  constructor(props) {
    super(props);
    this.currentTags = props.currentTags;

    this.state = {
      items: [],
      page: 1,
      isLastPage: true
    };
  }

  get currentPath() {
    return `/${this.currentTagParams}`;
  }

  loadItems(page) {
    var url = Routes.itemsPath({tag: this.currentTags, page: page});
    return $.getJSON(url).then((data) => {
      return {data, page};
    });
  }

  showMore() {
    return this.loadItems(this.state.page + 1).then(({data, page}) => {
      return this.setState({
        items: this.state.items.concat(data.items),
        page: page,
        isLastPage: data.isLastPage
      });
    });
  }

  onTagButtonsChanged(newTags) {
    const tags = newTags.map(tag => encodeURIComponent(tag));
    location.hash = `#/items/${tags.join(',')}`;
  }

  onCurrentTagsChanged() {
    this.loadItems(1).then(({data, page}) => {
      this.setState({
        items: data.items,
        page: page,
        isLastPage: data.isLastPage
      });
    });
  }

  componentDidMount() {
    this.loadItems(this.state.page).then(({data, page}) => {
      this.setState({
        items: data.items,
        page: page,
        isLastPage: data.isLastPage
      });
    });
  }

  render() {
    return (
      <div>
        {/* TODO: implement <tag-buttons v-with='tags: tags, currentTags: currentTags'></tag-buttons>*/}
        <div className='items'>
          {this.state.items.map(item =>
            <ItemPanel key={item.id} item={item}/>
          )}
        </div>
        {!this.state.isLastPage ?
          <div className='more text-center'>
            <button className='btn btn-primary' onClick={this.showMore.bind(this)}>続きを表示</button>
          </div> :
          null
        }
      </div>
    );
  }
}

module.exports = RootPage;
