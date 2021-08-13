import React, {useEffect, useState} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import ItemPanel from './ItemPanel';
import TagButtons from './TagButtons';
import WithPagination from './WithPagination';
import api from './Api';
import {PaginationValue, Tag, Item} from "./types";

export default withRouter(ItemsPage);

interface Props {
  currentTagNames: string[]
  currentPage: number
}

function itemsUrl(page: number, tags: Tag[]) {
  const tagParam = tags.map(tag => encodeURIComponent(tag.name)).join(',');
  return `/items/${page}/${tagParam}`
}

function ItemsPage({currentPage, currentTagNames, history}: Props & RouteComponentProps): JSX.Element {
  const [allTags, setAllTags] = useState<Tag[]>([]);
  const [items, setItems] = useState<Item[]>([]);
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
    api.loadItems(parameter).then(({items, pagination}: { items: Item[], pagination: PaginationValue }) => {
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
        <div className='my-3'>
          {items.map(item =>
            <ItemPanel key={item.id} item={item}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}
