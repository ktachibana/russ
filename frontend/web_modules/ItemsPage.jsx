import React from 'react';
import { withRouter } from 'react-router-dom';
import ItemPanel from 'ItemPanel';
import TagButtons from 'TagButtons';
import WithPagination from 'WithPagination';
import api from 'Api';

class ItemsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      tags: [],
      items: [],
      pagination: null
    };
  }

  get currentTags() {
    return this.selectTags(this.props.currentTagNames);
  }

  selectTags(tagNames) {
    return this.state.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateItems(props) {
    const query = {
      page: props.page,
      tag: props.currentTagNames
    };
    api.loadItems(query).then(({items, pagination}) => {
      this.setState({
        items: items,
        pagination: pagination
      });
    });
  }

  componentDidMount() {
    api.loadInitial().then((data) => {
      this.setState({tags: data.tags});
    });
    this.updateItems(this.props);
  }

  componentWillReceiveProps(nextProps) {
    this.updateItems(nextProps);
  }

  changeUrl({page = this.props.page, currentTagNames = this.props.currentTagNames}) {
    const tagParam = currentTagNames.map(tag => encodeURIComponent(tag)).join(',');
    this.props.history.push(`/items/${page}/${tagParam}`);
  }

  pagenationChanged(newPage) {
    this.changeUrl({page: newPage});
  }

  tagButtonsChanged(newTags) {
    this.changeUrl({currentTagNames: newTags.map(tag => tag.name)});
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.state.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
        <hr/>

        <WithPagination pagination={this.state.pagination}
                        currentPage={this.props.page}
                        onPageChange={this.pagenationChanged.bind(this)}>
          <div className='items'>
            {this.state.items.map(item =>
              <ItemPanel key={item.id} item={item}/>
            )}
          </div>
        </WithPagination>
      </div>
    );
  }
}

export default withRouter(ItemsPage);
