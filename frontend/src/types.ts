export interface User {
  email: string
}

export interface InitialState {
  user: User,
  tags: Tag[]
}

export interface ItemsResponse {
  items: Item[]
  pagination: PaginationValue
}

export interface FeedsResponse {
  subscriptions: Subscription[]
  pagination: PaginationValue
}

export interface Tag {
  id: number
  name: string
  count: number
}

export interface Subscription {
  id: number
  title: string
  userTitle: string
  hideDefault: boolean
  feed: Feed
  tags: Tag[]
  pagination: PaginationValue
}

export interface Feed {
  id: number
  url: string
  title: string
  linkUrl: string
  description: string
  items: Item[]
  latestItem?: Item
}

export interface UserFeed {
  id: number
  url: string
  title: string
  linkUrl: string
  description: string
  usersSubscription: Subscription
}

export interface Item {
  id: number
  publishedAt: string
  link: string
  title: string
  description: string
  feed?: UserFeed
}

export interface PaginationValue {
  totalCount: number
  perPage: number
}

export interface Message {
  id: string
  type: string
  text: string
}
