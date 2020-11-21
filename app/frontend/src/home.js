import React from 'react';
import { Link } from 'react-router-dom';

import { LoginForm } from './loginform';

export class Home extends React.Component {
    render(){
        var retVal = [];
        if(this.props.isAuthenticated === false) {
            retVal.push(<h1>Login</h1>);
            retVal.push(
                <LoginForm onProcessComplete={this.props.onProcessComplete} targetPath='/api/auth/login' />
            )
            retVal.push(
                <Link to="/register">Register</Link>
            );
        }
        else
            retVal.push(<p key="mainview">Use the menu</p>);

        return retVal
    }
}
