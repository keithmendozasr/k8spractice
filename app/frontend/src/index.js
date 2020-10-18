import React from 'react';
import ReactDOM from 'react-dom';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link,
  Redirect
} from 'react-router-dom';

import { Home } from './home';
import { Load } from './load';
import { NoMenu } from './nomenu';
import { LoginForm } from './loginform.js';

class App extends React.Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    componentDidMount() {
        fetch('/api/auth/checksession')
            .then(result => result.status === 200)
            .then(data => this.setState({ isAuthenticated: data }))
            .catch(error => console.error('Error occured: ' + error));
    }

    loginComplete() {
        this.setState({
            isAuthenticated: true
        });
    }

    registerComplete() {
        window.location.href="/";
    }

    render() {
        if(! ('isAuthenticated' in this.state)) {
            console.log('isAuthenticated not set');
            return ([]);
        }

        var menu = [];

        if(this.state.isAuthenticated)
            menu.push(
                <div className="collapse navbar-collapse" id="navbarSupportedContent">
                    <ul className="navbar-nav">
                        <li className="nav-item" key="menu-load">
                            <Link id="nav-load" to="/load" className="nav-link">Load</Link>
                        </li>
                        <li className="nav-item" key="menu-nomenu">
                            <Link id="nav-nomenu" to="/nomenu" className="nav-link">No Menu</Link>
                        </li>
                      </ul>
                </div>);

        return (
            <Router>
                <nav className="navbar navbar-expand-sm navbar-light">
                    <Link id="nav-home" to="/" className="navbar-brand">Home</Link>
                    <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span className="navbar-toggler-icon"></span>
                    </button>
                    {menu}
                </nav>
                <Switch>
                    <Route exact path="/load">
                        { this.state.isAuthenticated ? <Load /> : <Redirect to="/" /> }
                    </Route>
                    <Route exact path="/nomenu">
                        { this.state.isAuthenticated ? <NoMenu /> : <Redirect to="/" /> }
                    </Route>
                    <Route exact path="/register">
                        <h1>Register</h1>
                        <LoginForm onProcessComplete={this.registerComplete.bind(this)} targetPath="/api/auth/usermgnt" requestMethod="PUT" />
                    </Route>
                    <Route>
                        <Home onProcessComplete={this.loginComplete.bind(this)} isAuthenticated={this.state.isAuthenticated} />
                    </Route>
                </Switch>
            </Router>);
    }
}

ReactDOM.render(
    <App />,
    document.getElementById('root')
);
