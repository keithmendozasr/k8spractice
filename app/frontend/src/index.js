import React from 'react';
import ReactDOM from 'react-dom';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link,
} from 'react-router-dom';

import { Load } from './load';
import { NoMenu } from './nomenu';

ReactDOM.render(
  <Router>
    <nav className="navbar navbar-expand">
      <Link className="navbar-brand" to="/">Navbar</Link>
      <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span className="navbar-toggler-icon"></span>
      </button>
      <div className="collapse navbar-collapse" id="navbarSupportedContent">
        <ul className="navbar-nav">
          <li className="nav-item">
            <Link className="nav-link" to="/load">Load</Link>
          </li>
          <li className="nav-item">
            <Link className="nav-link" to="/nomenu">No Menu</Link>
          </li>
        </ul>
      </div>
    </nav>
    <Switch>
      <Route exact path="/load">
        <Load />
      </Route>
      <Route exact path="/nomenu">
        <NoMenu />
      </Route>
      <Route>
          <p>Use the menu</p>
      </Route>
    </Switch>
  </Router>,
  document.getElementById('root')
);
