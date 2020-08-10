import React from 'react';

export class BaseComponent extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            data: null,
            hasError: false,
        };
        this.apiTgt = null;
    }

    componentDidMount() {
        if(this.apiTgt) {
            fetch(this.apiTgt)
                .then(response => response.json())
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
                hasError: true
            });
        }
    }
}
