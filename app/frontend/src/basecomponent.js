import React from 'react';

export class BaseComponent extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            data: null,
            hasError: false,
            needToAuthenticate: false,
        };
        this.apiTgt = null;
    }

    componentDidMount() {
        if(this.apiTgt) {
            fetch(this.apiTgt)
                .then(response => {
                    if(response.ok)
                        return response.json();

                    if(response.status === 401) {
                        console.log('Need to login');
                        this.setState({
                            data:null,
                            hasError: false,
                            needToAuthenticate: true
                        });
                    }

                    return response.json()
                })
                .then(data => this.setState({
                    "data": data
                }))
                .catch(error => this.setState({
                    data: null,
                    hasError: true
                }));
        } else {
            console.error('apiTgt not set');
            this.setState({
                data: null,
                hasError: true,
                needToAuthenticate: false
            });
        }
    }
}
