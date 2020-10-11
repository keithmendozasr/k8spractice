import React from 'react';

import { LoginForm } from './loginform';

export class Home extends React.Component {
    constructor(props) {
        super(props);
    }

    render(){
        var retVal = [];
        if(this.props.isAuthenticated === false) {
            retVal.push(
                <LoginForm updateAuthenticateState={this.props.updateAuthenticateState} targetPath='/api/auth/login' />
            )
        }
        else
            retVal.push(<p key="mainview">Use the menu</p>);

        return retVal;
    }
}
