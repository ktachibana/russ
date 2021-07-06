import React, {useEffect, useState} from 'react';
import {withRouter} from 'react-router-dom';
import ItemPanel from 'ItemPanel';
import TagButtons from 'TagButtons';
import WithPagination from 'WithPagination';
import api from 'Api';

function itemsUrl(page, tags) {
  const tagParam = tags.map(tag => encodeURIComponent(tag.name)).join(',');
  return `/items/${page}/${tagParam}`
}

function ItemsPage({currentPage, currentTagNames, history}) {
  const [allTags, setAllTags] = useState([]);
  const [items, setItems] = useState([]);
  const [pagination, setPagination] = useState(null);

  const currentTags = selectTags(currentTagNames);


  function selectTags(tagNames) {
    return allTags.filter(tag => tagNames.includes(tag.name));
  }

  function updateItems() {
    const query = {
      page: currentPage,
      tag: currentTagNames,
      hideDefault: true
    };
    api.loadItems(query).then(({items, pagination}) => {
      setItems(items);
      setPagination(pagination);
    });
  }

  useEffect(() => {
    api.loadTags().then((tags) => {
      setAllTags(tags);
    });
  }, []);

  useEffect(() => {
    updateItems();
  }, [currentTagNames, currentTagNames]);

  function pushHistory({newPage = currentPage, newTags = currentTags}) {
    history.push(itemsUrl(newPage, newTags));
  }

  function changePage(newPage) {
    pushHistory({newPage})
  }

  function changeCurrentTags(newTags) {
    pushHistory({newTags});
  }

  return (
    <div>
      <TagButtons tags={allTags} currentTags={currentTags} onChange={(newTags) => {
        changeCurrentTags(newTags)
      }}/>
      <hr/>

      <WithPagination
        pagination={pagination}
        currentPage={currentPage}
        onPageChange={(newPage) => {
          changePage(newPage)
        }}>
        <div className='items'>
          {items.map(item =>
            <ItemPanel key={item.id} item={item}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}

export default withRouter(ItemsPage);
