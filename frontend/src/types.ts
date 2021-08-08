export interface Subscription {
  id: number
  userTitle: string
}

export interface Feed {
}

export interface UserFeed extends Feed{
  usersSubscription: Subscription
}

export interface Item {
  id: number
  publishedAt: string
  link: string
  title: string
  description: string
  feed: UserFeed
}

export interface Tag {
  id: number
  name: string
}

export interface PaginationValue {
  totalCount: number
  perPage: number
}
