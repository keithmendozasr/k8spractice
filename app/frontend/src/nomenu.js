import React from 'react';

import { BaseComponent } from './basecomponent';

export class NoMenu extends BaseComponent {
    constructor(props) {
        super(props);
        this.apiTgt = '/api/nomenu';
    }

    render() {
        if(this.state.hasError)
            return <p key="mainview">An error has occurred</p>;
        else if(!this.state.data)
            return <p key="mainview">Waiting for data</p>;
        else {
            return (Object.entries(this.state.data.body).map(([key,val], index) => {
                return <p key="someline-{key}">{key}: {val}</p>;
            }));
        }
    }
};
