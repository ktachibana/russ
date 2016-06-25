import React from 'react';
import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import ItemPanel from 'ItemPanel';
import TagButtons from 'TagButtons';

export default class ItemsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      items: [],
      page: 1,
      lastPage: true
    };
  }

  get currentTags() {
    return this.selectTags(this.props.params.tags);
  }

  selectTags(tagsParam) {
    const tagNames = (tagsParam || '').split(',');
    return this.props.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateItems({page = this.state.page, tagParam = this.props.params.tags}) {
    return new Promise((resolve, reject) => {
      const url = ApiRoutes.itemsPath({tag: tagParam ? tagParam.split(',') : [], page: page});
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

  tagButtonsChanged(newTags) {
    const tagNames = newTags.map(tag => encodeURIComponent(tag.name));
    location.hash = `#/items/${tagNames.join(',')}`;
  }

  componentDidMount() {
    this.updateItems({}).then(({loadedItems, setNextItems}) => {
      setNextItems(loadedItems);
    });
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.tags != this.props.params.tags) {
      this.updateItems({tagParam: nextProps.params.tags || null}).then(({loadedItems, setNextItems}) => {
        setNextItems(loadedItems);
      });
    }
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.props.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>

        <div className='items'>
          {this.state.items.map(item =>
            <ItemPanel key={item.id} item={item}/>
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
