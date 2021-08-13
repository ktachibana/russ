import React from 'react';
import {Link} from 'react-router-dom';

interface Props {
  userId: string
  onLogoutClick: () => void
}

export default function HeaderNav({userId, onLogoutClick}: Props): JSX.Element {
  function subscriptionBookmarklet() {
    const {protocol, host} = window.location;
    const apiURLBase = `${protocol}//${host}/#/subscriptions/new/`;
    const js = `location.href="${apiURLBase}"+encodeURIComponent(location.href);`;

    return `javascript:${js}`;
  }

  // TODO: PC版でもちゃんとしたレイアウト
  return (
    <nav className="navbar navbar-expand-sm navbar-light bg-light">
      <div className="container-fluid">
        <Link to="/items/1/" className="navbar-brand me-auto">
          RuSS
        </Link>
        <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#headerNavContent">
          <span className="navbar-toggler-icon"/>
        </button>

        <div id="headerNavContent" className="collapse navbar-collapse">
          <ul className="navbar-nav">
            <li className="nav-item">
              <Link to="/feeds/1/" className="nav-link">
                Feeds
              </Link>
            </li>
            <li className="nav-item dropdown">
              <a className="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button"
                 data-bs-toggle="dropdown"
                 aria-expanded="false">
                {userId}
              </a>

              <ul className="dropdown-menu">
                <li>
                  <a href={subscriptionBookmarklet()} className="dropdown-item">
                    RuSS (Bookmarklet)
                  </a>
                </li>
                <li>
                  <Link to="/subscriptions/import/" className="dropdown-item">
                    OPMLをインポート
                  </Link>
                </li>
                <li>
                  <hr className="dropdown-divider"/>
                </li>
                <li>
                  <a rel="nofollow" href="#" className="dropdown-item" onClick={() => { onLogoutClick() }}>
                    ログアウト
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  );
}
