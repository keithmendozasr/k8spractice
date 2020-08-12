import React from 'react';
import ReactDOM from 'react-dom';
import {
  BrowserRouter as Router,
  Switch,
  Route,
} from 'react-router-dom';

import { Load } from './load';
import { NoMenu } from './nomenu';

function App() {
    return (
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
    );
}

ReactDOM.render(
    <Router>
        <App />
    </Router>,
    document.getElementById('root')
);
