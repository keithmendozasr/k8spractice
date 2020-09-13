import React from 'react';

export class Home extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            creds: {
                user: '',
                password: ''
            },
            message: ''
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleChange(event) {
        const target = event.target;
        const name = target.name;
        var creds = this.state.creds;
        creds[name] = target.value
        this.setState({creds: creds });
    }

    handleSubmit(event) {
        event.preventDefault();

        this.setState({ 
            authenticationAttempted: false,
            creds: { user: '', password: '' },
            message: ''
        });

        fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(this.state.creds)
        })
        .then(response => {
            if(response.ok){
                this.setState({ isAuthenticated: true });
                this.props.updateAuthenticateState(this.state.isAuthenticated);
            } else {
                console.log('Authentication failed');
                this.setState({ 
                    isAuthenticated: false,
                    message: 'Authenticate failed'
                });
            }
            return response.json();
        })
        .catch(error => this.setState({
            isAuthenticated: false,
            creds: { user: '', password: '' }
        }));

    }

    render(){
        var retVal = [];
        if(this.state.message)
            retVal.push(<p>{this.state.message}</p>);

        if(this.props.isAuthenticated === false) {
            retVal.push(
                <form key="mainview" id="loginform" onSubmit={this.handleSubmit}>
                    <label>
                        User: 
                        <input type="text" name="user" value={this.state.creds.user} onChange={this.handleChange} />
                    </label><br />
                    <label>
                        Password
                        <input type="password" name="password" value={this.state.creds.password} onChange={this.handleChange} />
                    </label>
                    <input type="submit" name="submit" value="Submit" />
                </form>
            )
        }
        else
            retVal.push(<p key="mainview">Use the menu</p>);

        return retVal;
    }
}
