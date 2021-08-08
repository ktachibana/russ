import React, {useEffect, useState} from 'react';
import {withRouter} from 'react-router-dom';
import {History} from 'history';
import ItemPanel from './ItemPanel';
import TagButtons from './TagButtons';
import WithPagination from './WithPagination';
import api from './Api';
import {Item, PaginationValue, Tag} from "./types";

function itemsUrl(page: number, tags: Tag[]) {
  const tagParam = tags.map(tag => encodeURIComponent(tag.name)).join(',');
  return `/items/${page}/${tagParam}`
}

interface Props {
  currentTagNames: string[]
  currentPage: number
  history: History
}

function ItemsPage({currentPage, currentTagNames, history}: Props): JSX.Element {
  const [allTags, setAllTags] = useState([] as Tag[]);
  const [items, setItems] = useState([] as Item[]);
  const [pagination, setPagination] = useState<PaginationValue>();

  const currentTags = selectTags(currentTagNames);

  function selectTags(tagNames: string[]) {
    return allTags.filter(tag => tagNames.includes(tag.name));
  }

  function updateItems() {
    const parameter = {
      tag: currentTagNames,
      page: currentPage,
      hide_default: true
    };
    api.loadItems(parameter).then(({items, pagination}: {items: Item[], pagination: PaginationValue}) => {
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
  }, [currentPage, currentTagNames]);

  function pushHistory({newPage = currentPage, newTags = currentTags}) {
    history.push(itemsUrl(newPage, newTags));
  }

  function changePage(newPage: number) {
    pushHistory({newPage})
  }

  function changeCurrentTags(newTags: Tag[]) {
    pushHistory({newTags});
  }

  return (
    <div>
      <TagButtons tags={allTags} currentTags={currentTags} onChange={newTags => {
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
            <ItemPanel key={item.id} item={item} hideFeed={false}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}

export default withRouter(ItemsPage);